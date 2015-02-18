module PD
  module Base
    DEFAULT_STATUS  = Status::ALL
    DEFAULT_FIELDS  = %w( id status created_on html_url trigger_summary_data assigned_to_user service )

    def settings
      @settings ||= Config.settings
    end
  end
end
