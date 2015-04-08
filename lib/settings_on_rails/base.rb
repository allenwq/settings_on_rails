module SettingsOnRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_settings_on(column, options = {})
        column = column.to_sym
        raise InvalidColumnTypeError if column_type_not_text?(column)

        class << self; attr_accessor :_settings_column_name; end

        serialize column, Hash
        self._settings_column_name = column

        method_name = options[:method_name] || :settings
        define_method method_name do |*keys|
          if self.class._settings_column_name
            SettingsHandler.new(keys, self, self.class._settings_column_name)
          else
            raise NoSettingsColumnError
          end
        end
      end

      def has_settings
        raise NoSettingsColumnError unless _settings_column_name
        yield if block_given?
      end

      private
      def column_type_not_text?(column)
        return true if column_for_attribute(column).sql_type != 'text'
      end
    end
  end
end
