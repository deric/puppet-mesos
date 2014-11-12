require 'spec_helper'

describe 'mesos::master' do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos-master' }
  let(:file) { '/etc/default/mesos-master' }

  let(:params){{
    :conf_dir => conf,
    :owner    => owner,
    :group    => group,
  }}

  it { should contain_package('mesos') }
  it { should contain_service('mesos-master').with(
      :ensure => 'running',
      :enable => true
  ) }

  it { should contain_file(file).with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
  }) }

  it 'shoud not set any IP address by default' do
    should_not contain_file(
      file
    ).with_content(/^IP=/)
  end

  # no zookeeper set by default
  it { should contain_file(file).with_content(/ZK=""/) }

  it { should contain_file(file).with_content(/PORT=5050/) }

  it { should contain_file(file).with_content(/WHITELIST='*'/) }

  context 'with zookeeper' do
    let(:params){{
      :zookeeper => 'zk://192.168.1.100:2181/mesos',
    }}
    it { should contain_file(
      file).with_content(/ZK="zk:\/\/192.168.1.100:2181\/mesos"/)
    }
  end

  context 'setting master port' do
    let(:params){{
      :master_port => '4040',
    }}
    it { should contain_file(file).with_content(/PORT=4040/) }
  end

  context 'setting whitelist' do
    let(:params){{
      :whitelist => '/var/lib/mesos/whitelist',
    }}
    it { should contain_file(
      file).with_content(/WHITELIST='\/var\/lib\/mesos\/whitelist'/)
    }
  end

  it { should contain_file(file).with_content(/CLUSTER="mesos"/) }

  context 'setting cluster name' do
    let(:params){{
      :cluster => 'cluster',
    }}
    it { should contain_file(file).with_content(/CLUSTER="cluster"/) }
  end

  context 'setting environment variables' do
    let(:params){{
      :env_var => {
        'JAVA_HOME' => '/usr/bin/java',
        'MESOS_HOME' => '/var/lib/mesos',
      },
    }}

    it { should contain_file(
      file
    ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/) }

    it { should contain_file(
      file
    ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/) }
  end

  context 'disabling service' do
    let(:params){{
      :enable => false,
    }}

    it { should contain_service('mesos-master').with(
      :enable => false
    ) }
  end

  context 'changing master config file location' do
    let(:master_file) { '/etc/mesos/master' }
    let(:params){{
      :conf_file => master_file,
    }}

    it { should contain_file(master_file).with({
      'ensure'  => 'present',
      'mode'    => '0644',
    }) }
  end

  context 'set quorum via options' do
    let(:params){{
      :conf_dir => conf,
      :options => { 'quorum' => 4 },
    }}

    it 'has quorum file in master config dir' do
      should contain_file(
        "#{conf}/quorum"
      ).with_content(/^4$/).with({
      'ensure'  => 'present',
      })
    end
  end

  context 'allow changing conf_dir' do
    let(:my_conf_dir) { '/var/mesos-master'}
    let(:params){{
      :conf_dir => my_conf_dir,
      :options => { 'quorum' => 4 },
    }}

    it 'has quorum file in master config dir' do
      should contain_file(
        "#{my_conf_dir}/quorum"
      ).with_content(/^4$/).with({
      'ensure'  => 'present',
      })
    end
  end

  context 'work_dir' do
    let(:work_dir) { '/var/lib/mesos' }
    let(:params){{
      :conf_dir => conf,
      :work_dir => work_dir,
      :owner    => owner,
      :group    => group,
    }}


    it { should contain_file(work_dir).with({
      'ensure'  => 'directory',
      'owner'   => owner,
      'group'   => group,
    }) }
  end

  context 'support boolean flags' do
    let(:my_conf_dir) { '/var/mesos-master'}
    let(:params){{
      :conf_dir => my_conf_dir,
      :options => { 'authenticate' => true },
    }}

    it 'has authenticate file in config dir' do
      should contain_file(
        "#{my_conf_dir}/?authenticate"
      ).with({
      'ensure'  => 'present',
      })
    end
  end

end
