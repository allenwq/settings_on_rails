module SettingsOnRails

  class NoSettingsColumnError < StandardError
    def message
      'settings column not specified, have you declared has_settings_on before?'
    end
  end

  class ColumnNotExistError < StandardError
    def message
      'settings column does not exist, have you added the column in database?'
    end
  end

  class InvalidColumnTypeError < StandardError
    def message
      'type of settings column must be text'
    end
  end
end
