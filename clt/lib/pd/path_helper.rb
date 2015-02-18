module PD
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
end
