require 'bundler'
Bundler.require(:rake)
require 'rake/clean'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec-system/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
# blacksmith does not support ruby 1.8.7 anymore
require 'puppet_blacksmith/rake_tasks' if ENV['RAKE_ENV'] != 'ci' && RUBY_VERSION.split('.')[0, 3].join.to_i > 187

desc 'Lint metadata.json file'
task :meta do
  sh 'metadata-json-lint metadata.json'
end

exclude_paths = [
  'bundle/**/*',
  'pkg/**/*',
  'vendor/**/*',
  'spec/**/*'
]
Rake::Task[:lint].clear

PuppetLint.configuration.relative = true
PuppetLint.configuration.disable_80chars
PuppetLint.configuration.disable_class_inherits_from_params_class
PuppetLint.configuration.disable_class_parameter_defaults
PuppetLint.configuration.fail_on_warnings = true

PuppetLint::RakeTask.new :lint do |config|
  config.ignore_paths = exclude_paths
end

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task spec_prep: :librarian_spec_prep

task default: %i[validate spec lint]

desc "Run acceptance tests"
RSpec::Core::RakeTask.new(:acceptance) do |t|
  # just `spec/acceptance` caused runnin all specs
  t.pattern = 'spec/acceptance/*_spec.rb'
end
