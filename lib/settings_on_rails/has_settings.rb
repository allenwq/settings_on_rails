require 'settings_on_rails/key_tree_builder'

module SettingsOnRails
  # Creates a object to save default settings
  #
  # @param [Array] keys, the symbol keys in a array
  # @param [Class] target_model, default values will be saved in an class attribute in target model
  # @param [Symbol] column_name, the column name in target_model to save default values
  # @param [HasSettings] parent, parent has_settings object
  class HasSettings < KeyTreeBuilder
    def initialize(keys, target_model, column_name, parent = nil)
      super(keys, target_model, column_name, parent)

      @target_model = target_model
      @column_name = column_name
    end

    REGEX_ATTR = /\A([a-z]\w*)\Z/i

    # Declare a key, with default values
    #
    # @param [Symbol] keys
    # @param [Hash] options, the last param must be an option with a defaults hash
    def key(*keys)
      options = keys.extract_options!
      raise ArgumentError.new("has_settings: Option :defaults expected, but got #{options.keys.join(', ')}") unless options.blank? || (options.keys == [:defaults])
      keys.each do |key_name|
        raise ArgumentError.new("has_settings: symbol expected, but got a #{key_name.class}") unless key_name.is_a?(Symbol)
      end

      options[:defaults].each do |k, v|
        has_settings(*keys).attr(k, default: v)
      end
    end

    # Declare an attribute with default value
    #
    # @param [Symbol] value
    # @param [Hash] options, options with a default Hash
    def attr(value, options = {})
      raise ArgumentError.new("has_settings: symbol expected, but got a #{value.class}") unless value.is_a?(Symbol)
      raise ArgumentError.new("has_settings: Option :default expected, but got #{options.keys.join(', ')}") unless options.blank? || (options.keys == [:default])

      default_value = options[:default]
      raise 'Error' unless value.to_s =~ REGEX_ATTR

      _set_value(value.to_s, default_value)
    end

    def has_settings(*keys)
      settings = HasSettings.new(keys, @target_model, @column_name, self)
      yield settings if block_given?
      settings
    end

    private

    def _set_value(name, v)
      build_nodes

      if v.nil?
        current_node.delete(name)
      else
        current_node[name] = v
      end
    end
  end
end
