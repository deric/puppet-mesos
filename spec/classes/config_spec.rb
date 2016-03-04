require 'spec_helper'

describe 'mesos::config', :type => :class do

  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params){{
    :conf_dir => '/etc/mesos',
    :log_dir  => '/var/log/mesos',
    :owner    => owner,
    :group    => group,
  }}

  it { should contain_file('/etc/default/mesos').with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
    'require' => 'Package[mesos]',
  }) }

  it 'has default log dir' do
    should contain_file(
      '/etc/default/mesos'
    ).with_content(/LOGS="\/var\/log\/mesos"/)
  end

  it 'has default ulimit' do
    should contain_file(
      '/etc/default/mesos'
    ).with_content(/ULIMIT="-n 8192"/)
  end

  context 'conf_file' do
    let(:conf_file) { '/etc/sysconfig/mesos' }
    let(:params){{
      :conf_file => conf_file,
      :zookeeper_url => 'zk://10.0.0.1/mesos',
    }}

    it do
      should contain_file(conf_file)
    end
  end

  context 'setting ulimit' do
    let(:params){{
      :ulimit => 16384,
    }}

    it { should contain_file(
      '/etc/default/mesos'
      ).with_content(/ULIMIT="-n 16384"/)
    }
  end

  context 'setting log dir' do
    let(:params){{
      :log_dir => '/srv/mesos/log',
      :zookeeper_url => 'zk://10.0.0.1/mesos',
    }}
    it { should contain_file(
      '/etc/default/mesos'
      ).with_content(/LOGS="\/srv\/mesos\/log"/)
    }
  end

  context 'setting environment variables' do
    let(:params){{
      :env_var => {
        'JAVA_HOME' => '/usr/bin/java',
        'MESOS_HOME' => '/var/lib/mesos',
      },
    }}

    it { should contain_file(
      '/etc/default/mesos'
    ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/) }

    it { should contain_file(
      '/etc/default/mesos'
    ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/) }
  end

  context 'set LOGS variable' do
    let(:file) { '/etc/default/mesos' }
    let(:params) {{
      :log_dir => '/var/log/mesos',
    }}

    it { should contain_file(file).with_content(/LOGS="\/var\/log\/mesos"/) }
  end
end
