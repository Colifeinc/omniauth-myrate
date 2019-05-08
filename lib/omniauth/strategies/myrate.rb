require "omniauth/strategies/version"

require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Myrate < OmniAuth::Strategies::OAuth2
      # Give your strategy a name.
      option :name, "myrate"

      option :client_options, {
        :site => "https://n-license.firebaseapp.com/",
        :authorize_url => "https://n-license.firebaseapp.com//oauth/login",
        :token_url => "/oauth/access_token"
      }

      uid{ raw_info['id'] }

      info do
        {
          :name => raw_info['name'],
          :email => raw_info['email']
        }
      end

      extra do
        {
          'raw_info' => raw_info
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/me').parsed
      end
    end
  end
end