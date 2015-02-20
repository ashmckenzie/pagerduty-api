module PD
  class IncidentList

    # attr_reader :incident_list

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

    def prompt_user(incident, message)
      puts Formatters::Table.new([ incident ]).render
      message = "#{message} (y/n) "

      ask(message) do |q|
        q.validate = /y(es)?|n(o)?/i
      end
    end

    def resolve_all!(interactive: false)
      each_with_index do |incident, i|

        if interactive
          message = "Resolve? (%s/%s)" % [ i+1, total ]
          next unless prompt_user(incident, message) == /y(es)?/i
        end

        $logger.info "Resolving #{incident.inspect_short}" unless interactive
        incident.resolve!
      end
    end

    def acknowledge_all!(interactive: false)
      each_with_index do |incident, i|

        if interactive
          message = "Acknowledge? (%s/%s)" % [ i+1, total ]
          next unless prompt_user(incident, message) == /y(es)?/i
        end

        $logger.info "-> Acknowledging #{incident.inspect_short}" unless interactive
        incident.acknowledge!
      end
    end

    private

      attr_reader :raw_incident_list
  end
end
