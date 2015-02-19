module PD
  module Base
    DEFAULT_STATUS  = Status::ALL

    def settings
      @settings ||= $config.settings
    end

    def me
      @me ||= $config.me
    end
  end
end
