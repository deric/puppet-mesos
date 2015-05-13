source 'https://rubygems.org'

group :rake do
  puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 2.7.0','< 4.0']
  gem 'puppet', puppetversion
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper', '>=0.2.0'
  gem 'rake',         '>=0.9.2.2'
  gem 'rspec-system-puppet',     :require => false
  gem 'serverspec',              :require => false
  gem 'rspec-system-serverspec', :require => false
  gem 'librarian-puppet' , '< 2.0'
  gem 'highline', '~> 1.6.21' # 1.7 is not compatible with ruby 1.8.7
  gem 'rspec-puppet', '~> 2.0'
end

group :development do
  gem 'puppet-blacksmith',  '~> 3.0'
  gem 'metadata-json-lint',      :require => false
end
