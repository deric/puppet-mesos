require 'spec_helper'

describe 'mesos::install', :type => :class do

  context 'with given version' do
    let(:version) { '0.14' }
    let(:params) {{
      :ensure => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }

    # mesos dependencies (for web GUI)
    it { should_not contain_package('python').with({
      'ensure' => 'present'
    }) }

    it { should contain_class('mesos::repo') }
  end

  context 'manage python installation' do
    let(:params){{
        :manage_python => true,
      }}
    it { should contain_package('python') }
  end

  context 'remove packaged services' do
    context 'keeps everything' do
      it { should_not contain_file('/etc/init/mesos-master.conf') }
      it { should_not contain_file('/etc/init/mesos-slave.conf') }
    end

    context 'keeps everything on RHEL 7' do
      let(:facts) { {
          :osfamily => 'redhat',
          :operatingsystemmajrelease => '7',
      } }
      let(:params) { {
          :remove_package_services => true,
      } }

      it { should_not contain_file('/etc/init/mesos-master.conf') }
      it { should_not contain_file('/etc/init/mesos-slave.conf') }
    end

    context 'removes packaged upstart config on RHEL 6' do
      let(:facts) { {
          :osfamily => 'redhat',
          :operatingsystemmajrelease => '6',
      } }

      let(:params) { {
          :remove_package_services => true,
      } }

      it { should contain_file('/etc/init/mesos-master.conf').with_ensure('absent') }
      it { should contain_file('/etc/init/mesos-slave.conf').with_ensure('absent') }
    end
  end
end
