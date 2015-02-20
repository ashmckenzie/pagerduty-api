module PD
  class Incidents

    include Base
    include Status

    def all
      where
    end

    def where(status: DEFAULT_STATUS, fields: false, user_id: false, sort_by: 'created_on:desc')
      user_id = (user_id == false) ? settings.user_id : user_id
      incident_list = IncidentList.new(get(status, fields, user_id, sort_by))
      incident_list
    end

    private

      def get(status, fields, user_id, sort_by)
        options = {
          status:  status.join(','),
          sort_by: sort_by
        }

        options[:fields] = fields.join(',') if fields
        options[:assigned_to_user] = user_id unless user_id.nil?

        response = $connection.get('incidents', options)
        response.incidents.map { |raw_incident| Incident.new(raw_incident) }
      end
  end
end
