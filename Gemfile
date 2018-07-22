source 'https://rubygems.org'

group :rake do
  puppetversion = ENV.key?('PUPPET_VERSION') ? "#{ENV['PUPPET_VERSION']}" : ['>= 3.0.0','< 6.0']
  gem 'puppet', puppetversion
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper', '>=0.2.0'
  # removed method last_comment (requires rspec 3.5.0)
  gem 'rake'
  gem 'rspec-system-puppet',     :require => false
  gem 'highline'
  gem 'semantic_puppet'
  gem 'librarian-puppet' , '>=2.0'
  gem 'rspec-core', '>= 3.5.0'
  gem 'rspec-puppet'
  gem 'metadata-json-lint',      :require => false
  if RUBY_VERSION >= "2.2.0"
    gem 'safe_yaml'
  end
  if RUBY_VERSION >= "2.3.0"
    gem 'xmlrpc'
  end
  gem 'nokogiri', '~> 1.8.1'
end

group :development do
  gem 'rubocop', '>= 0.49.0'
  gem 'puppet-blacksmith', '< 4.0.0'
end