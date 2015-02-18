require 'dotenv'
require 'singleton'
require 'hashie'

require 'pager_duty/connection'

module PagerDutyAPI
  module Status
    ACKNOWLEDGED = 'acknowledged'
    RESOLVED     = 'resolved'
    TRIGGERED    = 'triggered'

    ALL = [ ACKNOWLEDGED, RESOLVED, TRIGGERED ]
  end

  module Base
    DEFAULT_STATUS  = Status::ALL
    DEFAULT_FIELDS  = %w( id created_on html_url trigger_summary_data assigned_to_user service )

    def settings
      @settings ||= Config.settings
    end
  end

  class Client
    include Base
    include Singleton

    def self.connection()  instance.connection; end

    def connection
      @pagerduty ||= PagerDuty::Connection.new(settings.account.name, settings.account.token)
    end
  end

  class PathHelper
    def self.incident_path(id)
      "incidents/%s" % [ id ]
    end

    def self.incident_acknowledge_path(id)
      "incidents/%s/acknowledge" % [ id ]
    end

    def self.incident_resolve_path(id)
      "incidents/%s/resolve" % [ id ]
    end
  end

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

  # i = Incident.find('PKWXX8T')
  class Incident
    include Base
    include Status

    attr_reader :raw

    def initialize raw
      @raw = raw
    end

    def self.find(id, fields: DEFAULT_FIELDS)
      path = PathHelper.incident_path(id)
      response = Client.connection.get(path, fields: fields.join(','))
      new(response)
    end

    def id
      @id ||= raw.id
    end

    def status
      @status ||= raw.status
    end

    def acknowledge?
      @ackd ||= raw.status == Status::ACKNOWLEDGED
    end

    def acknowledge!(force: false)
      return nil if acknowledge? && !force
      path = PathHelper.incident_acknowledge_path(id)
      Client.connection.put(path, requester_id: settings.user_id)
    end

    def resolved?
      @resolved ||= raw.status == Status::RESOLVED
    end

    def resolve!(force: false)
      return nil if resolved? && !force
      path = PathHelper.incident_resolve_path(id)
      Client.connection.put(path, requester_id: settings.user_id)
    end

  end

  class IncidentList

    def initialize(incidents)
      @incidents = incidents
    end

    def each
      return enum_for(:each) unless block_given?
      incidents.each { |incident| yield(incident) }
    end

    def resolve_all!
      each(&:resolve!)
    end

    def acknowledge_all!
      each(&:acknowledge!)
    end

    private

      attr_reader :incidents
  end

  class Incidents

    include Base
    include Status

    def all
      where
    end

    def where(status: DEFAULT_STATUS, fields: DEFAULT_FIELDS, user_id: nil)
      user_id ||= settings.user_id
      IncidentList.new(get(status.join(','), fields.join(','), user_id))
    end

    def self.where(status: DEFAULT_STATUS, fields: DEFAULT_FIELDS, user_id: nil)
      new.where(status: status, fields: fields, user_id: user_id)
    end

    def inspect
    end

    private

      def get(status, fields, user_id)
        response = Client.connection.get('incidents', fields: fields, assigned_to_user: user_id, status: status)
        response.incidents.map { |raw_incident| Incident.new(raw_incident) }
      end
  end
end
