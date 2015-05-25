module SettingsOnRails
  class KeyTreeBuilder
    attr_accessor :keys, :parent

    # All keys must be symbols, and attributes are strings
    # Thus we can differentiate settings(:key).attr and settings(:key, :attr)
    def initialize(keys, target_obj, target_column_name, parent)
      keys.each do |key_name|
        unless (key_name.is_a?(Symbol) || key_name.is_a?(String))
          raise ArgumentError.new("has_settings: symbol or string expected, but got a #{key_name.class}")
        end
      end
      @keys = keys.map(&:to_s)
      @target_obj = target_obj
      @column_name = target_column_name
      @parent = parent
    end

    # Returns column[key_chain[0]][key_chain[1]][...]
    def current_node
      return nil unless _key_node_exist?

      _key_chain.inject(_target_column) { |h, key| h[key] }
    end

    # Call this method before set any values
    def build_nodes
      value = _target_column

      for key in _key_chain
        value[key] = {} unless value[key]
        value = value[key]
      end
    end

    private

    def _key_node_exist?
      value = _target_column

      for key in _key_chain
        value = value[key]
        return false unless value
      end

      true
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

    def _target_column
      if @target_obj.respond_to?(:read_attribute)
        @target_obj.read_attribute(@column_name.to_sym)
      else
        @target_obj.send(@column_name.to_sym)
      end
    end
  end
end