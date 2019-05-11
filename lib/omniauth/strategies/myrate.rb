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

        response = access_token.post(
          '/oauth/access_token',
          headers: {
            'Content-Type': 'application/x-www-form-urlencoded'
          },
          body: {
            "grant_type": 'authorization_code',
            "code": request.params['code'],
            "client_id": options.client_id,
            "client_secret": options.client_secret,
            "redirect_uri": callback_url
          }
        )

        token = response.parsed
        log :debug, "got token from authorization api: #{token}"

        response = client.request(
          :get,
          "#{USER_INFO_URL}/#{token['myrate_id']}",
          headers: {
            "Authorization": "Bearer #{token['access_token']}"
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
