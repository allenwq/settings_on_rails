module SettingsOnRails
  module Base
    extend ActiveSupport::Concern

    module ClassMethods
      def has_settings_on(column, options = {}, &block)
        Configuration.init(self, column)

        method_name = options[:method] || :settings
        define_method method_name do |*keys|
          column = Configuration.check!(self)

          settings = Settings.new(keys, self, column, method_name)
          node = settings._current_node

          if node.nil? || node.is_a?(Hash)
            settings
          else
            node
          end
        end

        has_settings(&block)
      end

      def has_settings(*keys)
        settings = HasSettings.new(keys, self, Configuration::DEFAULTS_COLUMN)
        yield settings if block_given?

        settings
      end
    end
  end
end
