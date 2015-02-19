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

    def preferrered_time_zone
      @preferrered_time_zone ||= ENV['PAGERDUTY_PREFERRED_TIME_ZONE'] || raw.time_zone
    end

    private

      attr_reader :raw
  end

  NullUser = Naught.build do |config|
    config.mimic User

    def name
      'N/A'
    end
  end
end
