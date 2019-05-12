require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    # Main class for Myrate strategy.
    class Myrate < OmniAuth::Strategies::OAuth2
      USER_INFO_URL = 'https://n-license.firebaseapp.com/public/users'

      option :name, 'myrate'

      option :client_options, site: 'https://n-license.firebaseapp.com/',
                              authorize_url: 'https://n-license.firebaseapp.com/oauth/login',
                              token_url: '/oauth/access_token'

      uid { raw_info['uid'] }

      info do
        {
          email: raw_info['email'],
          nickname: raw_info['displayName']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        return @raw_info if @raw_info

        raise CallbackError.new(:invalid_token, 'Failed to get user data from userinfo api') if access_token['myrate_id'].empty?

        log :debug, "got access_token, token: #{access_token.token}, myrate_id: #{access_token['myrate_id']}"

        response = client.request(
          :get,
          "#{USER_INFO_URL}/#{access_token['myrate_id']}",
          headers: {
            "Authorization": "Bearer #{access_token.token}"
          }
        ).parsed

        log :debug, "got userinfo response: #{response}"
        raise CallbackError.new(:invalid_response, 'Failed to get user data from userinfo api') unless response['response'] == 'ok'

        @raw_info = response['userData']
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
