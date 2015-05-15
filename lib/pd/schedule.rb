module PD
  class Schedule

    def initialize(raw)
      @raw = raw
    end

    def name
      @name ||= raw.name
    end

    private

      attr_reader :raw

  end
end
