require 'spec_helper'

describe 'mesos::slave' do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos' }
  let(:file) { '/etc/mesos/slave.conf' }

  let(:facts) {{
    :ipaddress => '192.168.1.1',
  }}

  let(:params){{
    :conf_dir => conf,
    :owner    => owner,
    :group    => group,
  }}

  it { should contain_package('mesos') }
  it { should contain_service('mesos-slave').with(
      :ensure => 'running',
      :enable => true
  ) }

  it { should contain_file('/etc/mesos/slave.conf').with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
  }) }

  it 'has ip address from system fact' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^IP="192.168.1.1"$/)
  end

  it 'has default port eq to 5051' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^PORT=5051$/)
  end

  it 'checkpoint should be false' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^CHECKPOINT=false/)
  end

  it 'should have workdir in /tmp/mesos' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^WORKDIR="\/tmp\/mesos"/)
  end

  context 'one master node' do
    let(:params){{
      :master => '192.168.1.100',
    }}
    it { should contain_file(
      '/etc/mesos/slave.conf'
      ).with_content(/^MASTER="192.168.1.100:5050"/)
    }
  end

  context 'with zookeeper' do
    let(:params){{
      :zookeeper => 'zk://192.168.1.100:2181/mesos',
    }}
    it { should contain_file(
      '/etc/mesos/slave.conf'
      ).with_content(/^MASTER="zk:\/\/192.168.1.100:2181\/mesos"/)
    }
  end

  context 'zookeeper should be preferred before single master' do
    let(:params){{
      :master    => '172.16.0.1',
      :zookeeper => 'zk://192.168.1.100:2181/mesos',
    }}
    it { should contain_file(
      '/etc/mesos/slave.conf'
      ).with_content(/^MASTER="zk:\/\/192.168.1.100:2181\/mesos"/)
    }
  end

  context 'disabling service' do
    let(:params){{
      :enable => false,
    }}

    it { should contain_service('mesos-slave').with(
      :enable => false
    ) }
  end

  context 'changing workdir' do
    let(:params){{
      :work_dir => '/home/mesos',
    }}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^WORKDIR="\/home\/mesos"/) }
  end

  context 'changing checkpoint' do
    let(:params){{
      :checkpoint => true,
    }}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/CHECKPOINT=true/) }
  end

  context 'setting environment variables' do
    let(:params){{
      :env_var => {
        'JAVA_HOME' => '/usr/bin/java',
        'MESOS_HOME' => '/var/lib/mesos',
      },
    }}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/) }

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/) }
  end

  it 'should have isolation eq to process' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^ISOLATION="process"/)
  end

  it 'should not contain cgroups settings' do
    should_not contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^CGROUPS/)
  end

  context 'setting isolation mechanism' do
    let(:params){{
      :isolation => 'cgroups',
      :cgroups   => {
        'hierarchy' => '/sys/fs/cgroup',
        'root'      => 'mesos',
      }
    }}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^ISOLATION="cgroups"/)}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/^CGROUPS_HIERARCHY="\/sys\/fs\/cgroup"/)}

    it { should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/CGROUPS_ROOT="mesos"/)}
  end
end
