module SettingsOnRails
  module SettingsColumn
    DATA = :__settings_data

    def self.setup(klass, column)
      klass.class_eval do
        class << self; attr_accessor SettingsColumn::DATA; end

        serialize column, Hash
        self.send(SettingsColumn::DATA.to_s + '=', column.to_sym)
      end
    end

    # Returns the name of settings column for that instance
    def self.column_name(instance)
      instance.class.send(SettingsColumn::DATA)
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

    private
    def self.column_type_not_text?(instance, settings_column)
      return true if instance.column_for_attribute(settings_column).try(:sql_type) != 'text'
    end
  end
end
