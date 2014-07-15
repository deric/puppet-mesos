require 'spec_helper'

describe 'mesos::service' do
  let(:title) { 'slave' }

  shared_examples 'mesos-service' do |family, os, codename|
    let(:facts) {{
      :osfamily => family,
      :operatingsystem => os,
      :lsbdistcodename => codename,
    }}

    it { should contain_service('mesos-slave').with(
        :ensure     => 'running',
        :enable     => false,
        :hasstatus  => true,
        :hasrestart => true
    )}
    context 'enable service' do
      let(:params) {{
        :enable => true,
      }}

      it { should contain_service('mesos-slave').with(
        :enable => true
      )}
    end
  end

  context 'on debian-like system' do
    # last argument should be service provider
    it_behaves_like 'mesos-service', 'Debian', 'Debian'
    it_behaves_like 'mesos-service', 'Debian', 'Ubuntu'
  end

  context 'on red-hat-like system' do
    it_behaves_like 'mesos-service', 'RedHat', 'RedHat'
    it_behaves_like 'mesos-service', 'RedHat', 'CentOS'
  end

end
