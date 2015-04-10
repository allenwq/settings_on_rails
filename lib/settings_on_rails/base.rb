module SettingsOnRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_settings_on(column, options = {})
        SettingsColumn.setup(self, column)

        method_name = options[:method] || :settings
        define_method method_name do |*keys|
          column = SettingsColumn.check!(self)

          SettingsHandler.new(keys, self, column, method_name)
        end
      end

      def has_settings(*keys)
        settings = HasSettings.new(keys, self, SettingsColumn::DATA)
        yield settings if block_given?

        settings
      end
    end
  end
end
