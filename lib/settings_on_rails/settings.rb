require 'settings_on_rails/key_tree_builder'

module SettingsOnRails
  class Settings < KeyTreeBuilder
    def initialize(keys, target_object, settings_column_name, method_name, parent = nil)
      super(keys, target_object, settings_column_name, parent)
      @target_object = target_object
      @column_name = settings_column_name
      @method_name = method_name

      self.class_eval do
        define_method(method_name, instance_method(:_settings))
      end
    end

    REGEX_SETTER = /\A([a-z]\w*)=\Z/i
    REGEX_GETTER = /\A([a-z]\w*)\Z/i

    def respond_to?(method_name, include_priv=false)
      super || method_name.to_s =~ REGEX_SETTER
    end

    def method_missing(method_name, *args, &block)
      if method_name.to_s =~ REGEX_SETTER && args.size == 1
        _set_value($1, args.first)
      elsif method_name.to_s =~ REGEX_GETTER && args.size == 0
        value = _get_value($1)
        value.nil? ? _default_settings($1) : value
      else
        super
      end
    end

    private

    def _settings(*keys)
      raise ArgumentError, 'wrong number of arguments (0 for 1..n)' if keys.size == 0

      Settings.new(keys, @target_object, @column_name, @method_name, self)
    end

    def _get_value(name)
      node = current_node

      node[name] if node
    end

    def _set_value(name, v)
      return if _get_value(name) == v

      @target_object.send("#{@column_name}_will_change!")
      build_nodes

      if v.nil?
        current_node.delete(name)
      else
        current_node[name] = v
      end
    end

    def _default_settings(name)
      default_node = KeyTreeBuilder.new(keys, @target_object.class, Configuration::DEFAULTS_COLUMN, parent).current_node
      default_node[name] if default_node
    end
  end
end
