module SettingsOnRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_settings_on(column, options = {})
        SettingsColumn.setup(self, column)

        method_name = options[:method] || :settings
        define_method method_name do |*keys|
          column = SettingsColumn.check!(self)

          SettingsHandler.new(keys, self, column)
        end
      end

      def has_settings
        raise NoSettingsColumnError unless SettingsColumn::NAME
        yield if block_given?
      end
    end
  end
end
