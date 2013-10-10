

require 'active_record'


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

  module_function
  def setup(base_config = {}, pools = {})
    @base_config = base_config.symbolize_keys
    ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new(ConnectionPools.new(pools))
  end

  def with_connection_pool(config, &block)
    self.current_connection_pool_config = config = config.symbolize_keys
    if ActiveRecord::Base.connection_pool.nil?
      ActiveRecord::Base.establish_connection(@base_config.merge(config))
    end
    yield if block_given?
  ensure
    self.current_connection_pool_config = nil
  end

  def current_connection_pool_config
    Thread.current[:current_connection_pool_config]
  end

  def current_connection_pool_config=(config)
    Thread.current[:current_connection_pool_config] = config
  end
end
