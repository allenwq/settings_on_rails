module SettingsOnRails

  class NoSettingsColumnError < StandardError
    def message
      'Settings column not specified, have you declared has_settings_on before?'
    end
  end

  class InvalidColumnTypeError < StandardError
    def message
      'type of settings column must be text'
    end
  end
end
