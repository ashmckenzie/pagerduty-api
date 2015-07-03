module PD
  class User

    def initialize(raw)
      @raw = raw
    end

    def id
      @id ||= raw.id
    end

    def name
      @name ||= raw.name
    end

    def email
      @email ||= raw.email
    end

    def preferred_time_zone
      @preferred_time_zone ||= TZInfo::Timezone.get(time_zone)
      end

    private

      attr_reader :raw

      def raw_time_zone
        @raw_time_zone ||= begin
          if raw.time_zone == 'Pacific Time (US & Canada)'
            'US/Pacific'
          else
            raw.time_zone
          end
        end
      end

      def time_zone
        if ENV['PAGERDUTY_PREFERRED_TIME_ZONE']
          ENV['PAGERDUTY_PREFERRED_TIME_ZONE']
        else
          match = TZInfo::Timezone.all_identifiers.detect { |x| x.match(/#{raw_time_zone}/) }
          fail "Unable to accurately determine time zone based off '%s'" % raw_time_zone unless match
          match
        end
      end
  end

  NullUser = Naught.build do |config|
    config.mimic User

    def name
      'N/A'
    end
  end
end
