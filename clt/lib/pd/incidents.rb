module PD
  class Incidents

    include Base
    include Status

    def self.where(status: DEFAULT_STATUS, fields: DEFAULT_FIELDS, user_id: false)
      new.where(status: status, fields: fields, user_id: user_id)
    end

    def self.all
      new.all
    end

    def all
      where
    end

    def where(status: DEFAULT_STATUS, fields: DEFAULT_FIELDS, user_id: false)
      user_id = (user_id == false) ? settings.user_id : user_id
      IncidentList.new(get(status.join(','), fields.join(','), user_id))
    end

    private

      def get(status, fields, user_id)
        options = { status: status, fields: fields }
        options[:assigned_to_user] = user_id unless user_id.nil?

        response = Client.connection.get('incidents', options)
        response.incidents.map { |raw_incident| Incident.new(raw_incident) }
      end
  end
end
