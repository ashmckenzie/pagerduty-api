require 'dotenv'
require 'hashie'

module PD
  class Config
    include Singleton

    def self.settings()  instance.settings; end

    def initialize
      Dotenv.load('../.env', '../.env_development')
    end

    def settings
      @settings ||= begin
        Hashie::Mash.new(
          {
            account: {
              name:   ENV['PAGERDUTY_ACCOUNT_NAME']   || raise("Missing ENV['PAGERDUTY_ACCOUNT_NAME'], add to .env.development or .env"),
              token:  ENV['PAGERDUTY_ACCOUNT_TOKEN']  || raise("Missing ENV['PAGERDUTY_ACCOUNT_TOKEN'], add to .env.development or .env")
            },
            user_id:  ENV['PAGERDUTY_USER_ID']
          }
        )
      end
    end
  end
end
