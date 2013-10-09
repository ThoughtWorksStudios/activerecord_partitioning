

require 'active_record'


module ActiveRecordPartitioning

  # eager loading ConnectionHandler
  ActiveRecord::ConnectionAdapters::AbstractAdapter
  class Handler < ActiveRecord::ConnectionAdapters::ConnectionHandler
    def establish_connection(name, spec)
      @connection_pools[connection_pool_key(spec.config)] = ActiveRecord::ConnectionAdapters::ConnectionPool.new(spec)
    end

    def retrieve_connection_pool(klass)
      config = Thread.current[:current_connection_pool_config]
      pool = @connection_pools[connection_pool_key(config)]
      return pool if pool
      ActiveRecord::Base.establish_connection(config)
    end

    private
    def connection_pool_key(config)
      config['url']
    end
  end

  module_function
  def setup(pools = {})
    ActiveRecord::Base.connection_handler = Handler.new(pools)
  end

  def with_connection_pool(config)
    Thread.current[:current_connection_pool_config] = config
    yield
  ensure
    Thread.current[:current_connection_pool_config] = nil
  end

end
