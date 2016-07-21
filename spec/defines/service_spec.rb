require 'spec_helper'

describe 'mesos::service', :type => :define do
  let(:title) { 'slave' }

  before(:each) do
    puppet_debug_override
  end

  shared_examples 'mesos-service' do |family, os, codename, majdistrelease, release|
    let(:facts) {{
      :osfamily => family,
      :operatingsystem => os,
      :lsbdistcodename => codename,
      :majdistrelease => majdistrelease,
      :operatingsystemmajrelease => release,
    }}

    it { is_expected.to contain_service('mesos-slave').with(
        :ensure     => 'stopped',
        :enable     => false,
        :hasstatus  => true,
        :hasrestart => true
    )}
    context 'enable service' do
      let(:params) {{
        :enable => true,
      }}

      it { is_expected.to contain_service('mesos-slave').with(
        :enable => true,
        :ensure => 'running',
      )}
    end

    context 'do not manage service' do
      let(:params) {{
        :enable => true,
        :manage => false, # won't start service if it's not running
      }}

      it { is_expected.to contain_service('mesos-slave').with(
        :enable => true,
        :ensure => nil,
      )}
    end
  end

  context 'on debian-like system' do
    # last argument should be service provider
    it_behaves_like 'mesos-service', 'Debian', 'Debian', '7', 'wheezy'
    it_behaves_like 'mesos-service', 'Debian', 'Ubuntu', '12.04','precise'
  end

  context 'on red-hat-like system' do
    it_behaves_like 'mesos-service', 'RedHat', 'RedHat', '6', '6'
    it_behaves_like 'mesos-service', 'RedHat', 'CentOS', '7', '7'
  end

end
