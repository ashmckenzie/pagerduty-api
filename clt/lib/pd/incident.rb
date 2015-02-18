module PD
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

    def nodename
      @nodename ||= raw.trigger_summary_data.HOSTNAME
    end

    def acknowledged?
      @ackd ||= raw.status == Status::ACKNOWLEDGED
    end

    def acknowledge!(force: false)
      return nil if acknowledged? && !force
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
end
