module SettingsOnRails
  module SettingsColumn
    NAME = :__settings_column

    def self.setup(klass, column)
      klass.class_eval do
        class << self; attr_accessor SettingsColumn::NAME; end

        serialize column, Hash
        self.send(SettingsColumn::NAME.to_s + '=', column.to_sym)
      end
    end

    def self.column(instance)
      instance.class.send(SettingsColumn::NAME)
    end

    def self.check!(instance)
      settings_column = column(instance)
      raise NoSettingsColumnError unless settings_column
      raise InvalidColumnTypeError if column_type_not_text?(instance, settings_column)

      settings_column
    end

    private
    def self.column_type_not_text?(instance, settings_column)
      return true if instance.column_for_attribute(settings_column).try(:sql_type) != 'text'
    end
  end
end
