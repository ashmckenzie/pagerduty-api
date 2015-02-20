module PD
  module PathHelper
    def users_path(id)
      'users/%s' % [ id ]
    end

    def incident_path(id)
      'incidents/%s' % [ id ]
    end

    def incident_acknowledge_path(id)
      'incidents/%s/acknowledge' % [ id ]
    end

    def incident_resolve_path(id)
      'incidents/%s/resolve' % [ id ]
    end

    def incident_notes_path(id)
      'incidents/%s/notes' % [ id ]
    end

    def incident_log_entries_path(id)
      'incidents/%s/log_entries' % [ id ]
    end
  end
end
