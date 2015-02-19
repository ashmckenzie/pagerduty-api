module PD
  module Base
    DEFAULT_STATUS  = Status::ALL

    def settings
      @settings ||= $config.settings
    end
  end
end
