require 'active_record'
require 'activerecord_partitioning/connection_pools'

module ActiveRecordPartitioning
  module_function
  def setup(key_name, default_config = nil, store = {})
    self.default_config = default_config.try(:symbolize_keys)
    new_pools = ConnectionPools.new(key_name, store)
    new_pools.merge!(ActiveRecord::Base.connection_handler.connection_pools)
    ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new(new_pools)
  end

  def reset_connection_handler
    self.default_config = nil
    ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
  end

  def with_connection_pool(config, &block)
    config.try(:symbolize_keys!)
    origin = Thread.current[:current_connection_pool_config]
    Thread.current[:current_connection_pool_config] = (self.default_config || {}).merge(config || {})
    if ActiveRecord::Base.connection_pool.nil?
      ActiveRecord::Base.establish_connection(self.current_connection_pool_config)
    end
    yield if block_given?
  ensure
    ActiveRecord::Base.clear_active_connections!
    Thread.current[:current_connection_pool_config] = origin
  end

  def default_config
    @default_config
  end

  def default_config=(config)
    @default_config = config
  end

  def current_connection_pool_config
    Thread.current[:current_connection_pool_config]
  end
end
