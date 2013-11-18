require 'bundler'
Bundler.require(:rake)
require 'rake/clean'

CLEAN.include('spec/fixtures/modules', 'doc', 'pkg')
CLOBBER.include('.tmp', '.librarian')

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'rspec-system/rake_task'

PuppetLint.configuration.ignore_paths = ["spec/fixtures/modules/apt/manifests/*.pp"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send('disable_80chars')

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
  sh 'librarian-puppet install --path=spec/fixtures/modules/'
  sh 'mkdir -p spec/fixtures/manifests'
  sh 'touch spec/fixtures/manifests/site.pp'
  pwd = `pwd`.strip
  unless File.directory?("#{pwd}/spec/fixtures/modules/mesos")
    sh "ln -s #{pwd} #{pwd}/spec/fixtures/modules/mesos"
  end
end
task :spec_prep => :librarian_spec_prep

task :default => [:clean, :spec]