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
end
