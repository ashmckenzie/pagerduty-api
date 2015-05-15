module PD
  module Formatters
    module Schedules
      class Table

        def initialize(schedules)
          @schedules = schedules
          @prepared_rows = {}
        end

        def render
          return nil if schedules.empty?
          binding.pry
          puts Terminal::Table.new(headings: headings, rows: rows)
        end

        private

          attr_accessor :prepared_rows
          attr_reader :schedules

          def headings
            [
              'Name'
            ]
          end

          def rows
            schedules.map do |schedule|
              [
                schedule.name
              ]
            end
          end
      end
    end
  end
end
