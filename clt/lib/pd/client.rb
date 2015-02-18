require 'pager_duty/connection'

module PD
  class Client
    include Base
    include Singleton

    def self.connection() instance.connection; end

    def connection
      @pagerduty ||= PagerDuty::Connection.new(settings.account.name, settings.account.token)
    end
  end
end
