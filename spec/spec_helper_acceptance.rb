# frozen_string_literal: true

require 'beaker-rspec/spec_helper'
require 'beaker-rspec/helpers/serverspec'
require 'beaker/puppet_install_helper'

UNSUPPORTED_PLATFORMS = ['windows','AIX','Solaris'].freeze

HIERA_PATH = '/etc/puppetlabs/code/environments/production'

RSpec.configure do |c|
  proj_root = File.expand_path(File.join(File.dirname(__FILE__), '..'))

  c.formatter = :documentation
  hiera_config = '/etc/puppetlabs/puppet/hiera.yaml'

  # Configure all nodes in nodeset
  c.before :suite do
    #install_puppet
    hosts.each do |host|
      if ['RedHat'].include?(fact('osfamily'))
        on host, 'yum install -y tar'
      end
      #on host, 'gem install bundler'
      #on host, 'cd /etc/puppet && bundle install --without development'
      on host, puppet('module','install','puppetlabs-stdlib'), { :acceptable_exit_codes => [0,1] }
      on host, puppet('module','install','puppetlabs-apt'), { :acceptable_exit_codes => [0,1] }
      #binding.pry
      on host, "mkdir -p /etc/puppetlabs/puppet /etc/puppet/modules", { :acceptable_exit_codes => [0] }
      on host, "mkdir -p #{HIERA_PATH}", { :acceptable_exit_codes => [0] }
      scp_to host, File.expand_path('./spec/acceptance/hiera.yaml'), hiera_config
      # compatibility with puppet 3.x
      on host, "ln -s #{hiera_config} /etc/puppet/hiera.yaml", { :acceptable_exit_codes => [0] }
      on host, "ln -s #{HIERA_PATH}/hieradata /etc/puppetlabs/puppet/hieradata", { :acceptable_exit_codes => [0] }
      scp_to host, File.expand_path('./spec/acceptance/hieradata'), HIERA_PATH
      # assume puppet is on $PATH
      on host, "puppet --version"
      on host, "puppet module list"
    end
    puppet_module_install(source: proj_root, module_name: 'mesos')
  end
end
