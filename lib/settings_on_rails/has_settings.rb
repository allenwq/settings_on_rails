require 'settings_on_rails/key_tree_builder'

module SettingsOnRails
  class HasSettings
    attr_accessor :keys, :parent

    def initialize(keys, target_model, column, parent = nil)
      @keys = keys
      @target_model = target_model
      @column = column
      @parent = parent
      @builder = KeyTreeBuilder.new(self, target_model, column)
    end

    REGEX_ATTR = /\A([a-z]\w*)\Z/i

    def key(*keys)
      options = keys.last
      keys = keys[0...-1]
      raise ArgumentError.new('has_settings: Hash option is expected') unless options.is_a?(Hash)
      raise ArgumentError.new("has_settings: Option :defaults expected, but got #{options.keys.join(', ')}") unless options.blank? || (options.keys == [:defaults])
      keys.each do |key_name|
        raise ArgumentError.new("has_settings: symbol expected, but got a #{key_name.class}") unless key_name.is_a?(Symbol)
      end

      options[:defaults].each do |k, v|
        has_settings(*keys).attr(k, default: v)
      end
    end

    def attr(value, options = {})
      raise ArgumentError.new("has_settings: symbol expected, but got a #{value.class}") unless value.is_a?(Symbol)
      raise ArgumentError.new("has_settings: Option :default expected, but got #{options.keys.join(', ')}") unless options.blank? || (options.keys == [:default])

      default_value = options[:default]
      raise 'Error' unless value.to_s =~ REGEX_ATTR

      _set_value(value.to_s, default_value)
    end

    def has_settings(*keys)
      settings = HasSettings.new(keys, @target_model, @column, self)
      yield settings if block_given?
      settings
    end

    private

    def _set_value(name, v)
      @builder.build_nodes
      node = @builder.current_node

      if v.nil?
        node.delete(name)
      else
        node[name] = v
      end
    end
  end
end
