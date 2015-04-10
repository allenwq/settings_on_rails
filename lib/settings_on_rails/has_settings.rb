module SettingsOnRails
  class HasSettings
    PREFIX = '_'

    attr_accessor :keys, :parent
    def initialize(keys, target_model, column, parent = nil)
      @keys = _prefix(keys.dup)
      @target_model = target_model
      @column = column
      @parent = parent
    end

    REGEX_ATTR = /\A([a-z]\w*)\Z/i

    def key(*keys)
      return unless keys.last.is_a?(Hash) && keys.size >= 2

      options = keys.last
      options[:defaults].each do |k, v|
        has_settings(*keys[0...-1]).attr(k, default: v)
      end
    end

    def attr(value, options = {})
      default_value = options[:default]
      return unless default_value
      raise 'Error' unless value.to_s =~ REGEX_ATTR

      _set_value(value, default_value)
    end

    def has_settings(*keys)
      s = HasSettings.new(keys, @target_model, @column, self)
      yield s if block_given?
      s
    end

    private

    def _set_value(name, v)
      _build_key_tree
      node = _get_key_node
      if v.nil?
        node.delete(name)
      else
        node[name] = v
      end
    end

    def _key_node_exist?
      value = _target_column

      for key in _key_chain
          value = value[key]
          return false unless value
      end

      true
    end

    def _get_key_node
      ret = _key_node_exist?
      return nil unless ret

      _key_chain.inject(_target_column) { |h, key| h[key] }
    end

    def _build_key_tree
      value = _target_column

      for key in _key_chain
        value[key] = {} unless value[key]
        value = value[key]
      end
    end

    def _target_column
      @target_model.send(@column.to_sym)
    end

    # prefix keys with _, to differentiate `settings(:key_a, :key_b)` and settings(:key_a).key_b
    # thus _ becomes an reserved field
    def _prefix(keys)
      for i in 0..(keys.length - 1)
        keys[i] = (PREFIX + keys[i].to_s).to_sym
      end
      keys
    end

    # Returns a key chain which includes all parent's keys and self keys
    def _key_chain
      handler = self
      key_chain = []

      begin
        key_chain = handler.keys + key_chain
        handler = handler.parent
      end while handler

      key_chain
    end
  end
end
