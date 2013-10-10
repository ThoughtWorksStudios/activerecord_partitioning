module ActiveRecordPartitioning
  class NoActiveConnectionPoolError < StandardError
  end

  class ConnectionPools
    attr_reader :key_name, :store

    def initialize(key_name, store={})
      @key_name = key_name
      @store = store
    end

    def merge!(pools)
      pools.each do |klass_name, pool|
        self[klass_name] = pool
      end
    end

    def [](klass_name)
      config = ActiveRecordPartitioning.current_connection_pool_config
      raise NoActiveConnectionPoolError if config.nil?
      @store[connection_pool_key(config)]
    end

    def []=(klass_name, pool)
      @store[connection_pool_key(pool.spec.config)] = pool
    end

    def delete_if(&block)
      @store.delete_if(&block)
    end

    def each_value(&block)
      @store.each_value(&block)
    end

    def each(&block)
      @store.each(&block)
    end

    def size
      @store.size
    end

    private
    def connection_pool_key(config)
      config[@key_name]
    end
  end
end
