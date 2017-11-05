require "omniauth/strategies/oauth2"
require "faraday"

module OmniAuth
  module Strategies
    class Chatwork < ::OmniAuth::Strategies::OAuth2
      DEFAULT_SCOPE = "rooms.all:read_write"

      option :client_options, {
        site:          "https://api.chatwork.com/v2",
        authorize_url: "https://www.chatwork.com/packages/oauth2/login.php",
        token_url:     "https://oauth.chatwork.com/token",
        auth_scheme:   :basic_auth,
      }

      uid { raw_info["account_id"] }

      info do
        # via. https://github.com/omniauth/omniauth/wiki/Auth-Hash-Schema
        {
          "name" => raw_info["name"],
          "email" => raw_info["login_mail"],
          "description" => raw_info["introduction"],
          "image" => raw_info["avatar_image_url"],
          "urls" => {
            "profile" => raw_info["url"],
          },
        }
      end

      extra do
        hash = {}
        hash["raw_info"] = raw_info unless skip_info?
        hash
      end

      def raw_info
        @raw_info ||= access_token.get("me").parsed || {}
      end

      # You can pass +scope+ params to the auth request, if you need to set them dynamically.
      # You can also set these options in the OmniAuth config :authorize_params option.
      #
      # For example: /auth/chatwork?scope=rooms.all:read_write
      def authorize_params
        super.tap do |params|
          %w[scope].each do |v|
            if request.params[v]
              params[v.to_sym] = request.params[v]
            end
          end

          params[:scope] ||= DEFAULT_SCOPE
          params[:scope] = Array(params[:scope]).join(" ")
        end
      end

      def build_access_token
        verifier = request.params["code"]
        client.auth_code.get_token(verifier, {:redirect_uri => access_token_callback_url}.merge(token_params.to_hash(:symbolize_keys => true)), deep_symbolize(options.auth_token_params))
      end

      def access_token_callback_url
        # Remove query string from OmniAuth::Strategy#callback_url
        # https://github.com/omniauth/omniauth/blob/v1.7.1/lib/omniauth/strategy.rb#L438-L440
        options[:callback_url] || (full_host + script_name + callback_path)
      end
    end
  end
end
