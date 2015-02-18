module PD
  module Base
    DEFAULT_STATUS  = Status::ALL

    def settings
      @settings ||= Config.settings
    end
  end
end
