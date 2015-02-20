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

      def time_zone
        if ENV['PAGERDUTY_PREFERRED_TIME_ZONE']
          ENV['PAGERDUTY_PREFERRED_TIME_ZONE']
        else
          matches = TZInfo::Timezone.all_identifiers.select { |x| x.match(/#{raw.time_zone}/) }
          if matches.count == 1
            matches.first
          else
            fail "Unable to accurately determine time zone based off '%s'" % raw.time_zone
          end
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
