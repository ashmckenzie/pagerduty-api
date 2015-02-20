require 'dotenv'
require 'hashie'

module PD
  class Config
    include PathHelper   # FIXME

    def initialize
      Dotenv.load(config_file)
    end

    def settings
      @settings ||= begin
        Hashie::Mash.new(
          {
            account: {
              name:    ENV['PAGERDUTY_ACCOUNT_NAME']    || raise("Missing ENV['PAGERDUTY_ACCOUNT_NAME'], add to #{config_file}"),
              token:   ENV['PAGERDUTY_ACCOUNT_TOKEN']   || raise("Missing ENV['PAGERDUTY_ACCOUNT_TOKEN'], add to #{config_file}")
            },
            user_id:   ENV['PAGERDUTY_USER_ID']         || raise("Missing ENV['PAGERDUTY_USER_ID'], add to #{config_file}")
          }
        )
      end
    end

    def me
      @me ||= begin
        path = users_path(settings.user_id)
        User.new($connection.get(path).user)
      end
    end

    private

      def config_file
        File.join(ENV['HOME'], '.pagerduty_env')
      end
  end
end
