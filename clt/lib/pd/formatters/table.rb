module PD
  module Formatters
    class Table

      def initialize(incidents)
        @incidents = incidents
      end

      def render
        return nil if incidents.empty?
        puts Terminal::Table.new(headings: headings, rows: rows)
      end

      private

        attr_reader :incidents

        def headings
          [
            'Node',
            'Service',
            'Detail',
            'Assigned To',
            'Status',
            'Created'
          ]
        end

        def rows
          incidents.map do |incident|
            [
              incident.node.name,
              incident.service.name,
              incident.service.detail,
              incident.user.name,
              incident.status,
              incident.created_at
            ]
          end
        end

    end
  end
end
