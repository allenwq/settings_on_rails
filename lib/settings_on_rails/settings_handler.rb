module SettingsOnRails
  class SettingsHandler
    PREFIX = '_'

    attr_accessor :keys, :parent
    def initialize(keys, target_object, column, method_name, parent = nil)
      @keys = _prefix(keys.dup)
      @target_object = target_object
      @column = column
      @method_name = method_name
      @parent = parent

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
        _get_value($1)
      else
        super
      end
    end

    private
    def _settings(*keys)
      raise ArgumentError, 'wrong number of arguments (0 for 1..n)' if keys.size == 0

      SettingsHandler.new(keys, @target_object, @column, @method_name, self)
    end

    def _get_value(name)
      node = _get_key_node

      if node
        node[name]
      else
        nil
      end
    end

    def _set_value(name, v)
      return if _get_value(name) == v

      @target_object.send("#{@column}_will_change!")
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
      @target_object.read_attribute(@column.to_sym)
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
