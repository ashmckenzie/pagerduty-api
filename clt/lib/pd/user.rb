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

    private

      attr_reader :raw
  end
end
