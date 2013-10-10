require 'active_record'
require 'activerecord_partitioning/connection_pools'

module ActiveRecordPartitioning
  module_function
  def setup(key_name, base_config = {}, store = {})
    @base_config = base_config.symbolize_keys
    new_pools = ConnectionPools.new(key_name, store)
    new_pools.merge!(ActiveRecord::Base.connection_handler.connection_pools)
    ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new(new_pools)
  end

  def reset_connection_handler
    ActiveRecord::Base.connection_handler = ActiveRecord::ConnectionAdapters::ConnectionHandler.new
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
