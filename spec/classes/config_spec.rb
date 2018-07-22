require 'spec_helper'

describe 'mesos::config', type: :class do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params)  do
    {
      conf_dir: '/etc/mesos',
      log_dir: '/var/log/mesos',
      owner: owner,
      group: group
    }
  end

  # puppet 5 compatibility: make sure all dependent classes are loaded
  let :pre_condition do
    'include mesos::install'
  end

  before(:each) do
    puppet_debug_override
  end

  it {
    is_expected.to contain_file('/etc/default/mesos').with(
      'ensure' => 'present',
      'owner'   => owner,
      'group'   => group,
      'mode'    => '0644',
      'require' => 'Package[mesos]'
    )
  }

  it 'has default log dir' do
    is_expected.to contain_file(
      '/etc/default/mesos'
    ).with_content(/LOGS="\/var\/log\/mesos"/)
  end

  it 'has default ulimit' do
    is_expected.to contain_file(
      '/etc/default/mesos'
    ).with_content(/ULIMIT="-n 8192"/)
  end

  context 'conf_file' do
    let(:conf_file) { '/etc/sysconfig/mesos' }
    let(:params) do
      {
        conf_file: conf_file,
        zookeeper_url: 'zk://10.0.0.1/mesos'
      }
    end

    it do
      is_expected.to contain_file(conf_file)
    end
  end

  context 'setting ulimit' do
    let(:params) do
      {
        ulimit: 16_384
      }
    end

    it {
      is_expected.to contain_file(
        '/etc/default/mesos'
      ).with_content(/ULIMIT="-n 16384"/)
    }
  end

  context 'setting log dir' do
    let(:params) do
      {
        log_dir: '/srv/mesos/log',
        zookeeper_url: 'zk://10.0.0.1/mesos'
      }
    end
    it {
      is_expected.to contain_file(
        '/etc/default/mesos'
      ).with_content(/LOGS="\/srv\/mesos\/log"/)
    }
  end

  context 'setting environment variables' do
    let(:params) do
      {
        env_var: {
          'JAVA_HOME' => '/usr/bin/java',
          'MESOS_HOME' => '/var/lib/mesos'
        }
      }
    end

    it {
      is_expected.to contain_file(
        '/etc/default/mesos'
      ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/)
    }

    it {
      is_expected.to contain_file(
        '/etc/default/mesos'
      ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/)
    }
  end

  context 'set LOGS variable' do
    let(:file) { '/etc/default/mesos' }
    let(:params) do
      {
        log_dir: '/var/log/mesos'
      }
    end

    it { is_expected.to contain_file(file).with_content(/LOGS="\/var\/log\/mesos"/) }
  end
end
