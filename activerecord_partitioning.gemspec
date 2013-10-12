# -*- encoding: utf-8 -*-
Gem::Specification.new do |gem|
  gem.authors       = ["Xiao Li", "sdqali"]
  gem.email         = ["swing1979@gmail.com", "sadiqalikm@gmail.com"]
  gem.description   = "An ActiveRecord ConnectionPools class supports switching connection pool by database config instead of ActiveRecord model class name"
  gem.summary       = gem.description
  gem.homepage      = "https://github.com/ThoughtWorksStudios/activerecord_partitioning"
  gem.license       = 'MIT'

  gem.add_runtime_dependency 'activerecord', '2.3.18'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'sqlite3'

  gem.files = ['README.md']
  gem.files += Dir['lib/**/*.rb']

  gem.name          = "activerecord_partitioning"
  gem.require_paths = ["lib"]
  gem.version       = '0.1.2'
end
