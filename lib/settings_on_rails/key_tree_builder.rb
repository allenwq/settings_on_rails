module SettingsOnRails
  class KeyTreeBuilder
    def initialize(base, target_obj, target_column_name)
      @base_obj = base
      @target_obj = target_obj
      @column_name = target_column_name
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
      handler = @base_obj
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