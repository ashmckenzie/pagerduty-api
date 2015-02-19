require 'dotenv'
require 'hashie'

module PD
  class Config
    include PathHelper   # FIXME

    def initialize
      Dotenv.load('../.env', '../.env_development')
    end

    def settings
      @settings ||= begin
        Hashie::Mash.new(
          {
            account: {
              name:    ENV['PAGERDUTY_ACCOUNT_NAME']    || raise("Missing ENV['PAGERDUTY_ACCOUNT_NAME'], add to .env.development or .env"),
              token:   ENV['PAGERDUTY_ACCOUNT_TOKEN']   || raise("Missing ENV['PAGERDUTY_ACCOUNT_TOKEN'], add to .env.development or .env")
            },
            user_id:   ENV['PAGERDUTY_USER_ID']         || raise("Missing ENV['PAGERDUTY_USER_ID'], add to .env.development or .env")
          }
        )
      end
    end

    def me
      @me ||= begin
        path = users_path(settings.user_id)
        User.new(Client.connection.get(path).user)
      end
    end
  end
end
