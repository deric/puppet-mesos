require 'spec_helper'

describe 'mesos::slave' do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos-slave' }
  let(:slave_file) { '/etc/default/mesos-slave' }

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

  it { should contain_file(slave_file).with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
  }) }

  it 'does not set IP address by default' do
      should_not contain_file(
        slave_file
      ).with_content(/^IP=/)
  end

  context 'with ip address set' do

    let(:params) {{
      :listen_address => '192.168.1.1',
    }}

    it 'has ip address from param' do
      should contain_file(
        slave_file
      ).with_content(/^IP="192.168.1.1"$/)
    end
  end

  it 'has default port eq to 5051' do
    should contain_file(
      slave_file
    ).with_content(/^PORT=5051$/)
  end

  it 'checkpoint should be false' do
    should_not contain_file(
      "#{conf}/?checkpoint"
    ).with({
      'ensure'  => 'present',
    })
  end

  it 'should have workdir in /tmp/mesos' do
    should contain_file(
      "#{conf}/work_dir"
    ).with_content(/^\/tmp\/mesos$/)
  end

  context 'one master node' do
    let(:params){{
      :master => '192.168.1.100',
    }}
    it { should contain_file(
      slave_file
      ).with_content(/^MASTER="192.168.1.100:5050"/)
    }
    it { should contain_file(
      '/etc/mesos/zk'
      ).with(:ensure => 'absent')
    }
  end

  context 'zookeeper should be preferred before single master' do
    let(:params){{
      :master    => '172.16.0.1',
      :zookeeper => 'zk://192.168.1.100:2181/mesos',
    }}
    it { should_not contain_file(
      slave_file
      ).with_content(/^MASTER="172.16.0.1"/)
    }
    # this would work only if we set mesos::zookeeper through hiera
    #it { should contain_file(
    #  '/etc/mesos/zk'
    #  ).with_content(/^zk:\/\/192.168.1.100:2181\/mesos/)
    #}
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
      "#{conf}/work_dir"
    ).with_content(/^\/home\/mesos$/) }
  end

  context 'enabling checkpoint (enabled by default anyway)' do
    let(:params){{
      :options => {
        'checkpoint' => true,
      }
    }}

    it { should contain_file(
      "#{conf}/?checkpoint"
    ).with({
      'ensure'  => 'present',
    }) }
  end

  context 'disabling checkpoint' do
    let(:params){{
      :options => {
        'checkpoint' => false,
      }
    }}

    it { should contain_file(
      "#{conf}/?no-checkpoint"
    ).with({
      'ensure'  => 'present',
    }) }
  end

  context 'setting environment variables' do
    let(:params){{
      :env_var => {
        'JAVA_HOME' => '/usr/bin/java',
        'MESOS_HOME' => '/var/lib/mesos',
      },
    }}

    it { should contain_file(
      slave_file
    ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/) }

    it { should contain_file(
      slave_file
    ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/) }
  end

  it 'should not set isolation by default (value depends on mesos version)' do
    should_not contain_file(
      "#{conf}/isolation"
    ).with({
      'ensure'  => 'present',
    })
  end

  context 'should set isolation to cgroups' do
    let(:params){{
      :isolation => 'cgroups/cpu,cgroups/mem',
    }}

    it { should contain_file(
      "#{conf}/isolation"
    ).with({
      'ensure'  => 'present',
    }).with_content(/^cgroups\/cpu,cgroups\/mem$/) }
  end

  it 'should not contain cgroups settings' do
    should_not contain_file(
      slave_file
    ).with_content(/^CGROUPS/)
  end

  context 'setting isolation mechanism' do
    let(:params){{
      :isolation => 'cgroups/cpu,cgroups/mem',
      :cgroups   => {
        'hierarchy' => '/sys/fs/cgroup',
        'root'      => 'mesos',
      }
    }}

    it { should contain_file(
      "#{conf}/cgroups_root"
    ).with_content(/^mesos$/)}

    it { should contain_file(
      "#{conf}/cgroups_hierarchy"
    ).with_content(/^\/sys\/fs\/cgroup$/)}

    it { should contain_file(
      "#{conf}/isolation"
    ).with({
      'ensure'  => 'present',
    }).with_content(/^cgroups\/cpu,cgroups\/mem$/) }
  end

  context 'changing slave config file location' do
    let(:slave_file) { '/etc/mesos/slave' }
    let(:params){{
      :conf_file => slave_file,
    }}

    it { should contain_file(slave_file).with({
      'ensure'  => 'present',
      'mode'    => '0644',
    }) }
  end

  context 'resources specification' do
    let(:resources_dir) { '/etc/mesos-slave/resources' }

    let(:params){{
      :resources   => {
        'cpu' => '4',
        'mem' => '2048',
      }
    }}

    it { should contain_file(resources_dir).with({
      'ensure'  => 'directory',
    }) }

    it { should contain_file(
      "#{resources_dir}/cpu"
    ).with_content(/^4$/)}

    it { should contain_file(
      "#{resources_dir}/mem"
    ).with_content(/^2048$/)}
  end

  context 'custom ipaddress fact' do
    let(:facts) {{
      :ipaddress_eth0 => '192.168.1.2',
    }}

    let(:params){{
      :conf_dir => conf,
      :owner    => owner,
      :group    => group,
      :listen_address => '$::ipaddress_eth0'
    }}

    # fact is not evaluated in test with newer puppet (or rspec)
    xit 'has ip address from system fact' do
      should contain_file(
        slave_file
      ).with_content(/^IP="192.168.1.2"$/)
    end
  end

   context 'set isolation via options' do
    let(:params){{
      :conf_dir => conf,
      :options => { 'isolation' => 'cgroups/cpu,cgroups/mem' },
    }}

    it 'contains isolation file in slave directory' do
      should contain_file(
        "#{conf}/isolation"
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    end
  end


  context 'allow changing config directory' do
    let(:my_conf_dir) { '/var/mesos-slave' }
    let(:params){{
      :conf_dir => my_conf_dir,
      :options => { 'isolation' => 'cgroups/cpu,cgroups/mem' },
    }}

    it 'contains isolation file in slave directory' do
      should contain_file(
        "#{my_conf_dir}/isolation"
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    end
  end

  context 'work_dir' do
    let(:work_dir) { '/tmp/mesos' }
    let(:params){{
      :conf_dir => conf,
      :work_dir => work_dir,
      :owner    => owner,
      :group    => group,
    }}

    it { should contain_file(
      "#{conf}/work_dir"
    ).with_content(/\/tmp\/mesos/) }

    it { should contain_file(work_dir).with({
      'ensure'  => 'directory',
      'owner'   => owner,
      'group'   => group,
    }) }
  end

  context 'support boolean flags' do
    let(:my_conf_dir) { '/var/mesos-slave'}
    let(:params){{
      :conf_dir => my_conf_dir,
      :options => { 'strict' => false },
    }}

    it 'has no-strict file in config dir' do
      should contain_file(
        "#{my_conf_dir}/?no-strict"
      ).with({
      'ensure'  => 'present',
      })
    end
  end
end
