require "test/unit"

require "activerecord_partitioning"

class ActiveRecordPartitioningTest < Test::Unit::TestCase
  def test_setup_new_connection_pool_by_config
    ActiveRecordPartitioning.setup
    config = ActiveRecordPartitioning.with_connection_pool('adapter' => 'sqlite3', 'url' => 'database url') do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal 'database url', config[:url]
  end

  def test_should_merge_default_spec_config
    ActiveRecordPartitioning.setup(default_config)
    config = ActiveRecordPartitioning.with_connection_pool('url' => 'new database url') do
      ActiveRecord::Base.connection_pool.spec.config
    end
    assert_equal({:adapter => 'sqlite3', :url => 'new database url'}, config)
  end

  def test_should_raise_error_when_accessing_connection_pool_without_specifying_pool_config
    ActiveRecordPartitioning.with_connection_pool('adapter' => 'sqlite3', 'url' => 'database url')
    assert_raise ActiveRecordPartitioning::NoActiveConnectionPoolError do
      ActiveRecord::Base.connection_pool
    end
  end

  def test_remove_connection
    ActiveRecordPartitioning.setup
    ActiveRecordPartitioning.with_connection_pool('adapter' => 'sqlite3', 'url' => 'database url') do
      assert ActiveRecord::Base.remove_connection
    end
    assert_equal 0, ActiveRecord::Base.connection_handler.connection_pools.size
  end

  def default_config
    {'adapter' => 'sqlite3', 'url' => 'database url'}
  end
end
