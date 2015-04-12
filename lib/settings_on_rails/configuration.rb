module SettingsOnRails
  module Configuration
    NAME_COLUMN = :settings_column_name
    DEFAULTS_COLUMN = :default_settings

    def self.init(klass, column)
      klass.class_eval do
        class_attribute Configuration::NAME_COLUMN, Configuration::DEFAULTS_COLUMN

        serialize column, Hash
        Configuration::init_defaults_column(self)
        Configuration::init_name_column(self, column.to_sym)
      end
    end

    # Returns the name of settings column for that instance
    def self.column_name(instance)
      instance.class.send(Configuration::NAME_COLUMN)
    end

    # Check for the validity of the settings column
    # Returns the column name if valid
    def self.check!(instance)
      settings_column_name = column_name(instance)
      raise NoSettingsColumnError unless settings_column_name
      raise ColumnNotExistError unless instance.has_attribute?(settings_column_name)
      raise InvalidColumnTypeError if column_type_not_text?(instance, settings_column_name)

      settings_column_name
    end

    # init to Hash {} for data attribute in klass if nil
    def self.init_defaults_column(klass)
      defaults = klass.send(Configuration::DEFAULTS_COLUMN)
      klass.send(Configuration::DEFAULTS_COLUMN.to_s + '=', {}) unless defaults
    end

    def self.init_name_column(klass, column_name)
      klass.send(Configuration::NAME_COLUMN.to_s + '=', column_name)
    end


    private

    def self.column_type_not_text?(instance, settings_column)
      return true if instance.column_for_attribute(settings_column).try(:sql_type) != 'text'
    end
  end
end
