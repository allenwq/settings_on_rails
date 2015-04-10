module SettingsOnRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_settings_on(column, options = {}, &block)
        SettingsColumn.setup(self, column)

        method_name = options[:method] || :settings
        define_method method_name do |*keys|
          column = SettingsColumn.check!(self)

          Settings.new(keys, self, column, method_name)
        end

        has_settings(&block)
      end

      def has_settings(*keys)
        settings = HasSettings.new(keys, self, SettingsColumn::DEFAULTS_COLUMN)
        yield settings if block_given?

        settings
      end
    end
  end
end
