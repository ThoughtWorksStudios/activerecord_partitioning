module ActiveRecordPartitioning
  class NoActiveConnectionPoolError < StandardError
  end

  class ConnectionPools
    attr_reader :store

    def initialize(store={})
      @store = store
    end

    def [](key)
      config = ActiveRecordPartitioning.current_connection_pool_config
      raise NoActiveConnectionPoolError if config.nil?
      @store[connection_pool_key(config)]
    end

    def []=(key, pool)
      @store[connection_pool_key(pool.spec.config)] = pool
    end

    def delete_if(&block)
      @store.delete_if(&block)
    end

    def each_value(&block)
      @store.each_value(&block)
    end

    def size
      @store.size
    end

    private
    def connection_pool_key(config)
      config[:url]
    end
  end
end
