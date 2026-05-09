require "omniauth-oauth2"

module OmniAuth
  module Strategies
    class Kakao < OmniAuth::Strategies::OAuth2
      option :name, "kakao"

      option :client_options, {
        site: "https://kapi.kakao.com",
        authorize_url: "https://kauth.kakao.com/oauth/authorize",
        token_url: "https://kauth.kakao.com/oauth/token"
      }

      uid { raw_info["id"].to_s }

      info do
        {
          name: raw_info.dig("kakao_account", "profile", "nickname") ||
                raw_info.dig("properties", "nickname"),
          email: raw_info.dig("kakao_account", "email"),
          image: raw_info.dig("kakao_account", "profile", "profile_image_url") ||
                 raw_info.dig("properties", "profile_image")
        }
      end

      extra do
        { raw_info: raw_info }
      end

      def raw_info
        @raw_info ||= access_token.get("/v2/user/me").parsed
      end

      def callback_url
        full_host + script_name + callback_path
      end
    end
  end
end
