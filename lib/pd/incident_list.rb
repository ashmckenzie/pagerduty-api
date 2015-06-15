module PD
  class IncidentList

    include Base
    include PathHelper

    def initialize(raw_incident_list)
      @raw_incident_list = raw_incident_list
    end

    def incident_list
      @incident_list ||= begin
        jobs = []
        raw_incident_list.each do |incident|
          jobs << Thread.new { incident.fetch! }
        end
        jobs.each(&:join)
        raw_incident_list
      end
    end

    def each
      return enum_for(:each) unless block_given?
      incident_list.each { |incident| yield(incident) }
    end

    def each_with_index
      return enum_for(:each_with_index) unless block_given?
      incident_list.each_with_index { |incident, i| yield(incident, i) }
    end

    def map
      return enum_for(:map) unless block_given?
      incident_list.map { |incident| yield(incident) }
    end

    def select
      return enum_for(:select) unless block_given?
      incident_list.select { |incident| yield(incident) }
    end

    def reject
      return enum_for(:reject) unless block_given?
      incident_list.reject { |incident| yield(incident) }
    end

    def detect
      return enum_for(:detect) unless block_given?
      incident_list.detect { |incident| yield(incident) }
    end

    def empty?
      incident_list.empty?
    end

    def total
      incident_list.count
    end

    def resolve_all!
      incidents = incident_list.map { |i| { id: i.id, status: Status::RESOLVED } }
      if incidents.empty?
        $logger.info 'All incidents already resolved'
        return true
      end

      $logger.debug 'Attempting to resolve all incidents'
      puts Formatters::Incidents::Table.new(incident_list).render
      return unless prompt('Are you sure?').match(/y(es)?/i)

      options = { incidents: incidents, requester_id: settings.user_id }
      $connection.put(incidents_path, options.to_json)
    end

    def resolve!
      each_with_index do |incident, i|
        message = "Resolve? (%s/%s)" % [ i+1, total ]
        next unless prompt_user(incident, message).match(/y(es)?/i)
        incident.resolve!
      end
    end

    def acknowledge_all!
      incidents = incident_list.map { |i| { id: i.id, status: Status::ACKNOWLEDGED } }
      if incidents.empty?
        $logger.info 'All incidents already acknowledged'
        return true
      end

      $logger.debug 'Acknowledging all incidents'
      puts Formatters::Incidents::Table.new(incident_list).render
      return unless prompt('Are you sure?').match(/y(es)?/i)

      options = { incidents: incidents, requester_id: settings.user_id }
      $connection.put(incidents_path, options.to_json)
    end

    def acknowledge!
      each_with_index do |incident, i|
        message = 'Acknowledge? (%s/%s)' % [ i+1, total ]
        next unless prompt_user(incident, message).match(/y(es)?/i)
        incident.acknowledge!
      end
    end

    private

      attr_reader :raw_incident_list

      def prompt_user(incident, message)
        puts Formatters::Incidents::Table.new([ incident ]).render
        prompt(message)
      end

      def prompt(message)
        message = "#{message} (y/n) "
        ask(message) do |q|
          q.validate = /y(es)?|n(o)?/i
          q.default = 'y'
        end
      end

  end
end
