require 'bundler'
Bundler.require(:rake)
require 'rake/clean'

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec-system/rake_task'
require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet_blacksmith/rake_tasks' if RUBY_VERSION.split('.')[0,3].join.to_i > 187


exclude_paths = [
  "pkg/**/*",
  "spec/fixtures/modules/**/*.pp"
]
PuppetLint.configuration.ignore_paths = exclude_paths
PuppetSyntax.exclude_paths = exclude_paths
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send('disable_80chars')
PuppetLint.configuration.send('disable_autoloader_layout')

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
end
task :spec_prep => :librarian_spec_prep if RUBY_VERSION.split('.')[0,3].join.to_i > 187

task :default => [:spec]
