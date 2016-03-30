source 'https://rubygems.org'

group :rake do
  puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.0.0','< 4.0']
  gem 'puppet', puppetversion
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper', '>=0.2.0'
  gem 'rake',         '>=0.9.2.2'
  gem 'rspec-system-puppet',     :require => false
  gem 'serverspec',              :require => false
  gem 'rspec-system-serverspec', :require => false
  gem 'librarian-puppet' , '>=2.0'
  gem 'highline'
  gem 'rspec-puppet'
  # in order to support Ruby 1.9.3
  gem 'fog-google', '< 0.1.1'
  gem 'metadata-json-lint',      :require => false
  gem 'parallel_tests'
end

group :development do
  gem 'puppet-blacksmith',  '~> 3.0'
end
