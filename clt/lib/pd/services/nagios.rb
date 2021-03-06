module PD
  module Services
    class Nagios

      attr_reader :node, :raw

      def initialize(node, raw)
        @node = node
        @raw = raw
      end

      def name
        @service ||= raw.service
      end

      def state
        @state ||= raw.state
      end

      def detail
        @detail || begin
          raw.details.SERVICEOUTPUT.gsub('br /', "\n")
        end
      end
    end
  end
end
