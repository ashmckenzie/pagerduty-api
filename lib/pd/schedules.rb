module PD
  class Schedules

    include Base
    include PathHelper   # FIXME

    def all
      where
    end

    def where(query: nil)
      get(query)
    end

    private

      def get(query)
        options = {}
        options[:query] = query if query

        response = $connection.get(schedules_path)
        response.schedules.map do |raw_schedule_summary|
          raw_schedule_detailed = $connection.get(schedule_path(raw_schedule_summary.id), options)
          Schedule.new(raw_schedule_detailed.schedule)
        end
      end

  end
end
