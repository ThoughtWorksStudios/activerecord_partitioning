require "test/unit"

require "activerecord_partitioning"

class ActiveRecordPartitioningTest < Test::Unit::TestCase

  def teardown
    ActiveRecordPartitioning.reset_connection_handler
  end

  def test_setup_new_connection_pool_by_config
    ActiveRecordPartitioning.setup(:database)
    config1 = ActiveRecordPartitioning.with_connection_pool(default_config) do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal '/tmp/db', config1[:database]

    config2 = ActiveRecordPartitioning.with_connection_pool(default_config.merge('database' => '/tmp/db1')) do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal '/tmp/db1', config2[:database]

    config3 = ActiveRecordPartitioning.with_connection_pool(default_config) do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal config1, config3
  end

  def test_should_merge_default_spec_config
    ActiveRecordPartitioning.setup(:database, default_config)
    config = ActiveRecordPartitioning.with_connection_pool('database' => '/tmp/newdb') do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal({:adapter => 'sqlite3', :database => '/tmp/newdb'}, config)
  end

  def test_should_raise_error_when_accessing_connection_pool_without_specifying_pool_config
    ActiveRecordPartitioning.setup(:database)
    ActiveRecordPartitioning.with_connection_pool(default_config)
    assert_raise ActiveRecordPartitioning::NoActiveConnectionPoolError do
      ActiveRecord::Base.connection_pool
    end
    ActiveRecordPartitioning.setup(:database, default_config)
    assert ActiveRecord::Base.connection_pool
  end

  def test_should_use_default_config_if_no_config_specified
    assert_nil ActiveRecordPartitioning.current_connection_pool_config

    ActiveRecordPartitioning.setup(:database, default_config)
    assert_equal default_config.symbolize_keys, ActiveRecordPartitioning.current_connection_pool_config
  end


  def test_remove_connection
    ActiveRecordPartitioning.setup(:database)
    ActiveRecordPartitioning.with_connection_pool(default_config) do
      assert ActiveRecord::Base.remove_connection
    end
    assert_equal 0, ActiveRecord::Base.connection_handler.connection_pools.size
  end

  def test_should_not_lose_existing_connection_pool_when_setup_partitioning
    ActiveRecord::Base.establish_connection(default_config)
    pool = ActiveRecord::Base.connection_pool
    ActiveRecordPartitioning.setup(:database)
    assert_equal 1, ActiveRecord::Base.connection_handler.connection_pools.size
    assert_equal({'/tmp/db' => pool}, ActiveRecord::Base.connection_handler.connection_pools.store)
  end

  def default_config
    {'adapter' => 'sqlite3', 'database' => '/tmp/db'}
  end
end
