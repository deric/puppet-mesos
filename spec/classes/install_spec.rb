require 'spec_helper'

describe 'mesos::install', type: :class do
  let(:facts) do
    {
      osfamily: 'Debian',
      os: {
        family: 'Debian',
        name: 'Debian',
        distro: { codename: 'stretch' },
        release: { major: '9', minor: '1', full: '9.1' }
      },
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      puppetversion: Puppet.version
    }
  end

  context 'with given version' do
    let(:version) { '1.5' }
    let(:params) do
      {
        ensure:      version,
        repo_source: 'mesosphere',
      }
    end


    before(:each) do
      puppet_debug_override
    end

    it {
      should contain_package('mesos').with(
        'ensure' => version
      )
    }

    # mesos dependencies (for web GUI)
    it {
      should_not contain_package('python').with(
        'ensure' => 'present'
      )
    }

    it { should contain_class('mesos::repo') }
  end

  context 'do not install repo' do
    let(:params)  do
      {
        manage_repo: false
      }
    end
    it { is_expected.not_to contain_class('mesos::repo') }
  end


  context 'manage python installation' do
    let(:params)  do
      {
        manage_python: true
      }
    end
    it { should contain_package('python') }
  end

  context 'remove packaged services' do
    context 'keeps everything' do
      it { should_not contain_file('/etc/init/mesos-master.conf') }
      it { should_not contain_file('/etc/init/mesos-slave.conf') }
    end

    context 'keeps everything on RHEL 7' do
      let(:facts) do
        {
          osfamily: 'redhat',
          operatingsystemmajrelease: '7'
        }
      end
      let(:params) do
        {
          remove_package_services: true
        }
      end

      it { should_not contain_file('/etc/init/mesos-master.conf') }
      it { should_not contain_file('/etc/init/mesos-slave.conf') }
    end

    context 'removes packaged upstart config on RHEL 6' do
      let(:facts) do
        {
          osfamily: 'redhat',
          operatingsystemmajrelease: '6'
        }
      end

      let(:params) do
        {
          remove_package_services: true
        }
      end

      it { should contain_file('/etc/init/mesos-master.conf').with_ensure('absent') }
      it { should contain_file('/etc/init/mesos-slave.conf').with_ensure('absent') }
    end
  end
end
