module PD
  class IncidentList

    attr_reader :list

    def initialize(list)
      @list = list
    end

    def each
      return enum_for(:each) unless block_given?
      list.each { |incident| yield(incident) }
    end

    def map
      return enum_for(:map) unless block_given?
      list.map { |incident| yield(incident) }
    end

    def select
      return enum_for(:select) unless block_given?
      list.select { |incident| yield(incident) }
    end

    def reject
      return enum_for(:reject) unless block_given?
      list.reject { |incident| yield(incident) }
    end

    def detect
      return enum_for(:detect) unless block_given?
      list.detect { |incident| yield(incident) }
    end

    def resolve_all!
      each do |incident|
        $logger.info "Resolving #{incident.id}"
        incident.resolve!
      end
    end

    def acknowledge_all!
      each do |incident|
        $logger.info "Ack'ng #{incident.id}"
        incident.acknowledge!
      end
    end
  end
end
