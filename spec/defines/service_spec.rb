require 'spec_helper'

describe 'mesos::service' do
  let(:title) { 'slave' }

  shared_examples 'mesos-service' do |family, os, codename, provider|
    let(:facts) {{
      :osfamily => family,
      :operatingsystem => os,
      :lsbdistcodename => codename,
      :os_maj_version => codename,
    }}

    it { should contain_service('mesos-slave').with(
        :ensure     => 'running',
        :enable     => false,
        :hasstatus  => true,
        :hasrestart => true,
        :provider   => provider
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
    it_behaves_like 'mesos-service', 'Debian', 'Debian', 'wheezy'
    it_behaves_like 'mesos-service', 'Debian', 'Ubuntu', 'precise'
  end

  context 'on red-hat-like system < 7' do
    it_behaves_like 'mesos-service', 'RedHat', 'RedHat', 6, 'upstart'
    it_behaves_like 'mesos-service', 'RedHat', 'CentOS', 6, 'upstart'
  end
  context 'on red-hat-like system' do
    it_behaves_like 'mesos-service', 'RedHat', 'RedHat', 7, nil
    it_behaves_like 'mesos-service', 'RedHat', 'CentOS', 7, nil
  end

end
