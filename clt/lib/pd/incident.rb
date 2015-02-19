require 'tzinfo'

module PD
  class Incident

    include Base
    include Status
    extend PathHelper   # FIXME
    include PathHelper  # FIXME

    attr_reader :raw

    def initialize raw
      @raw = raw
    end

    def self.find(id, fields: false)
      path = incident_path(id)
      options = {}
      options[:fields] = fields.join(',') if fields
      response = Client.connection.get(path, options)
      new(response)
    end

    def inspect
      attrs = [ self.class.name, id, node.name, service.name, service.detail, user.name, status, created_at ]
      '<%s id:[%s] node:[%s] service:[%s] detail:[%s] assigned_to:[%s] status:[%s] created_at:[%s]>' % attrs
    end

    def inspect_short
      attrs = [ self.class.name, node.name, service.name, service.detail ]
      '<%s node:[%s] service:[%s] detail:[%s]>' % attrs
    end

    def id
      @id ||= raw.id
    end

    def status
      @status ||= raw.status
    end

    def user
      @user ||= raw.assigned_to_user ? User.new(raw.assigned_to_user) : NullUser.new
    end

    def link
      @link ||= raw.html_url
    end

    def created_at
      @created_at ||= raw.created_on.in_time_zone(me.preferrered_time_zone)
    end

    def notes
      @notes ||= begin
        path = incident_notes_path(id)
        Client.connection.get(path).notes.map { |raw_note| Note.new(raw_note) }
      end
    end

     def node
      @node ||= Node.new(raw.trigger_summary_data.HOSTNAME)
    end

    def log_entries
      @log_entrues ||= begin
        path = incident_log_entries_path(id)
         Client.connection.get(path, include: [ 'channel' ]).log_entries.map { |raw_log_entry| LogEntry.new(raw_log_entry) }
      end
    end

    def service
      @services ||= begin
        log_entry = triggers.detect { |trigger| [ 'nagios' ].include?(trigger.channel.type) }
        Services::Nagios.new(node, log_entry.channel) if log_entry
      end
    end

    def acknowledged?
      @ackd ||= raw.status == Status::ACKNOWLEDGED
    end

    def acknowledge!(force: false)
      return nil if acknowledged? && !force
      path = incident_acknowledge_path(id)
      Client.connection.put(path, requester_id: settings.user_id)
    end

    def resolved?
      @resolved ||= raw.status == Status::RESOLVED
    end

    def resolve!(force: false)
      return nil if resolved? && !force
      path = incident_resolve_path(id)
      Client.connection.put(path, requester_id: settings.user_id)
    end

    private

      def triggers
        @triggers ||= log_entries.select { |log_entry| log_entry.type == 'trigger' }
      end

  end
end
