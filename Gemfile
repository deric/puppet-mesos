source 'https://rubygems.org'

group :rake do
  puppetversion = ENV.key?('PUPPET_VERSION') ? (ENV['PUPPET_VERSION']).to_s : ['>= 3.0.0', '< 6.0']
  gem 'puppet', puppetversion
  gem 'puppet-lint'
  gem 'puppetlabs_spec_helper', '>=0.2.0'
  # removed method last_comment (requires rspec 3.5.0)
  gem 'highline'
  gem 'librarian-puppet', '>=2.0'
  gem 'metadata-json-lint', require: false
  gem 'nokogiri', '>= 1.10.4'
  gem 'rake'
  gem 'rspec-core', '>= 3.5.0'
  gem 'rspec-puppet'
  gem 'rspec-system-puppet', require: false
  gem 'safe_yaml' if RUBY_VERSION >= '2.2.0'
  gem 'semantic_puppet'
  gem 'xmlrpc' if RUBY_VERSION >= '2.3.0'
  gem 'parallel_tests'
end

group :development do
  gem 'puppet-blacksmith', git: 'https://github.com/deric/puppet-blacksmith', branch: 'tag-order'
  gem 'rubocop', '>= 0.49.0'
  gem 'rubocop-rspec'
  gem 'rubocop-i18n'
end

group :system_tests do
  gem 'pry'
  gem 'beaker'
  gem 'beaker-rspec'
  gem 'beaker-docker'
  gem 'serverspec'
  gem 'beaker-hostgenerator'
  gem 'beaker-puppet_install_helper'
  gem 'master_manipulator'
end
