require "test/unit"

require "activerecord_partitioning"

class ActiveRecordPartitioningTest < Test::Unit::TestCase

  def teardown
    ActiveRecordPartitioning.reset
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

  def test_setup_default_config
    ActiveRecordPartitioning.setup(:database, default_config)
    assert_equal default_config.symbolize_keys, ActiveRecordPartitioning.default_config
  end

  def test_should_merge_default_spec_config
    ActiveRecordPartitioning.setup(:database, default_config)
    config = ActiveRecordPartitioning.with_connection_pool('database' => '/tmp/newdb') do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal({:adapter => 'sqlite3', :database => '/tmp/newdb'}, config)
  end

  def test_with_connection_pool_should_handle_nil_config_argument
    ActiveRecordPartitioning.setup(:database, default_config)
    config = ActiveRecordPartitioning.with_connection_pool(nil) do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal(default_config.symbolize_keys, config)
  end

  def test_should_always_get_connection_pool_if_there_is_only_one
    ActiveRecordPartitioning.setup(:database)
    pool = ActiveRecordPartitioning.with_connection_pool(default_config) do
      ActiveRecord::Base.connection_pool
    end
    assert_equal pool, ActiveRecord::Base.connection_pool
  end

  def test_should_return_nil_when_there_is_no_connection_pool
    ActiveRecordPartitioning.setup(:database)

    assert_nil ActiveRecord::Base.connection_pool

    ActiveRecordPartitioning.with_connection_pool(default_config)
    assert ActiveRecord::Base.connection_pool
  end

  def test_should_raise_error_when_no_pool_specified_and_there_are_more_than_two_pools
    ActiveRecordPartitioning.setup(:database)

    ActiveRecordPartitioning.with_connection_pool(default_config)
    ActiveRecordPartitioning.with_connection_pool(default_config.merge('database' => '/tmp/db2'))

    assert_raise ActiveRecordPartitioning::NoActiveConnectionPoolError do
      ActiveRecord::Base.connection_pool
    end
    pool = ActiveRecordPartitioning.with_connection_pool(default_config) { ActiveRecord::Base.connection_pool }
    assert pool
  end

  def test_no_current_connection_pool_config_by_default
    ActiveRecordPartitioning.setup(:database)
    assert_nil ActiveRecordPartitioning.current_connection_pool_config
    ActiveRecordPartitioning.with_connection_pool(default_config) do
      assert ActiveRecordPartitioning.current_connection_pool_config
    end
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

  def test_switch_connection_pool_multiple_times
    ActiveRecordPartitioning.setup(:database, default_config)
    ActiveRecordPartitioning.with_connection_pool('database' => '/tmp/db1') do
      ActiveRecordPartitioning.with_connection_pool('database' => '/tmp/db2') do
        assert_equal '/tmp/db2', ActiveRecord::Base.connection_pool.spec.config[:database]
      end
      assert_equal '/tmp/db1', ActiveRecord::Base.connection_pool.spec.config[:database]
    end
  end

  def default_config
    {'adapter' => 'sqlite3', 'database' => '/tmp/db'}
  end
end
