require 'spec_helper'

describe 'mesos::slave', :type => :class do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos-slave' }
  let(:slave_file) { '/etc/default/mesos-slave' }

  let(:params){{
    :conf_dir => conf,
    :owner    => owner,
    :group    => group,
  }}

  let(:facts) do
    {
      :mesos_version => '0.28.2',
      :osfamily => 'Debian',
      :operatingsystem => 'Debian',
      :lsbdistcodename => 'jessie',
      :majdistrelease => '8',
      :operatingsystemmajrelease => 'jessie',
      :path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      :puppetversion => Puppet.version,
    }
  end

  before(:each) do
    puppet_debug_override
  end

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
      ).with_content(/^export MESOS_IP=/)
  end

  context 'with ip address set' do

    let(:params) {{
      :listen_address => '192.168.1.1',
    }}

    it 'has ip address from param' do
      should contain_file(
        slave_file
      ).with_content(/^export MESOS_IP="192.168.1.1"$/)
    end
  end

  it 'has default port eq to 5051' do
    should contain_file(
      slave_file
    ).with_content(/^export MESOS_PORT=5051$/)
  end

  it 'checkpoint should be false' do
    should_not contain_file(
      "#{conf}/?checkpoint"
    ).with({
      'ensure'  => 'present',
    })
  end

  it 'should have workdir in /var/lib/mesos' do
    should contain_file(
      "#{conf}/work_dir"
    ).with_content(/^\/var\/lib\/mesos$/)
  end

  context 'one master node' do
    let(:params){{
      :master => '192.168.1.100',
    }}
    it { should contain_file(
      slave_file
      ).with_content(/^export MESOS_MASTER="192.168.1.100:5050"/)
    }
    it { should contain_file(
      '/etc/mesos/zk'
      ).with(:ensure => 'absent')
    }
  end

  context 'zookeeper should be preferred before single master' do
    let(:params){{
      :master    => '172.16.0.1',
      :zookeeper => [ '192.168.1.100:2181' ],
    }}
    it { should_not contain_file(
      slave_file
      ).with_content(/^export MESOS_MASTER="172.16.0.1"/)
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
    ).with_content(/CGROUPS/)
  end

  context 'setting isolation mechanism' do
    let(:params){{
      :isolation => 'cgroups/cpu,cgroups/mem',
      :cgroups   => {
        'hierarchy' => '/sys/fs/cgroup',
        'root'      => 'mesos',
      },
      :owner     => owner,
      :group     => group,
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

    it { should contain_mesos__property('slave_hierarchy').with({
      'owner'   => owner,
      'group'   => group,
      'dir'     => conf,
      'value'   => '/sys/fs/cgroup',
    }) }
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

  context 'custom listen_address value' do
    let(:params){{
      :conf_dir => conf,
      :owner    => owner,
      :group    => group,
      :listen_address => '192.168.1.2',
    }}

    # fact is not evaluated in test with newer puppet (or rspec)
    it 'has ip address from system fact' do
      should contain_file(
        slave_file
      ).with_content(/IP="192\.168\.1\.2"$/)
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

    it do
      should contain_file(work_dir).with({
        'ensure'  => 'directory',
        'owner'   => owner,
        'group'   => group,
      })
    end

    it do
      should contain_mesos__property('slave_work_dir').with({
        'owner' => owner,
        'group' => group,
        'dir'   => conf,
        'value' => work_dir,
      })
    end

    it do
      should contain_file("#{conf}/work_dir")
        .with_content(work_dir + "\n")
        .that_requires("File[#{conf}]")
    end
  end

  context 'common slave config' do
    let(:params){{
      :zookeeper      => 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos',
      :listen_address => '192.168.1.1',
      :attributes     => {
        'env' => 'production',
      },
      :resources => {
        'ports' => '[10000-65535]'
      },
    }}

    it { should compile.with_all_deps }
    it { should contain_package('mesos') }
    it { should contain_service('mesos-slave').with(
      :ensure => 'running',
      :enable => true
    ) }

    it { should contain_mesos__property('resources_ports').with({
      'dir'     => '/etc/mesos-slave/resources',
      'file'    => 'ports',
      'value'   => '[10000-65535]',
    }) }


    it { should contain_mesos__property('attributes_env').with({
      'dir'     => '/etc/mesos-slave/attributes',
      'file'    => 'env',
      'value'   => 'production',
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

   context 'nofify service after removing a key' do
    let(:my_conf_dir) { '/tmp/mesos-conf'}
    let(:params){{
      :conf_dir => my_conf_dir,
    }}

    before(:each) do
      system("mkdir -p #{my_conf_dir} && touch #{my_conf_dir}/foo")
    end

    after(:each) do
      system("rm -rf #{my_conf_dir}")
    end

    it { is_expected.to contain_service('mesos-slave') }
    it { is_expected.to contain_file("#{my_conf_dir}").that_notifies('Service[mesos-slave]') }
  end

  context 'nofify service after removing a key' do
    let(:my_conf_dir) { '/tmp/mesos-conf'}
    let(:params){{
      :conf_dir => my_conf_dir,
    }}

    before(:each) do
      system("mkdir -p #{my_conf_dir}/resources && echo 2 > #{my_conf_dir}/resources/cpus")
    end

    after(:each) do
      system("rm -rf #{my_conf_dir}")
    end

    it { is_expected.to contain_service('mesos-slave') }
    it { is_expected.to contain_file("#{my_conf_dir}").that_notifies('Service[mesos-slave]') }
  end

  context 'credentials' do
    context 'default w/o principal/secret' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
      } }

      it 'has no credentials property' do
        should_not contain_mesos__property(
                       'slave_credential'
                   )
      end

      it 'has not credentials file' do
        should contain_file(
                   '/etc/mesos/slave-credentials'
               )
                   .with({
                             'ensure' => 'absent',
                         })
      end
    end

    context 'w/ principal/secret' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
          :principal => 'some-mesos-principal',
          :secret => 'a-very-secret',
      } }

      it 'has credentials property' do
        should contain_mesos__property(
                   'slave_credential'
               ).with({
                          'value' => '/etc/mesos/slave-credentials',
                      })
      end

      it 'has credentials file' do
        should contain_file(
                   '/etc/mesos/slave-credentials'
               ).with({
                          'ensure' => 'file',
                          'content' => '{"principal": "some-mesos-principal", "secret": "a-very-secret"}',
                          'owner' => owner,
                          'group' => group,
                          'mode' => '0400',
                      })
      end
    end

    context 'syslog logger' do
      describe 'when syslog_logger is true' do
        let(:params) do
          {
            :conf_dir => conf,
            :owner => owner,
            :group => group,
            :syslog_logger => true
          }
        end
        it do
          should contain_mesos__property('slave_logger')
            .with(
              :ensure => 'absent',
              :file => 'logger',
              :value => false,
              :dir => conf,
              :owner => owner,
              :group => group
            )

          should contain_file("#{conf}/?no-logger").with_ensure('absent')
        end
      end

      describe 'when syslog_logger is false' do
        let(:params) do
          {
            :conf_dir => conf,
            :owner => owner,
            :group => group,
            :syslog_logger => false
          }
        end
        it do
          should contain_mesos__property('slave_logger')
            .with(
              :ensure => 'present',
              :file => 'logger',
              :value => false,
              :dir => conf,
              :owner => owner,
              :group => group
            )

          should contain_file("#{conf}/?no-logger").with_ensure('present')
        end
      end
    end
  end

  context 'single role' do
    it { should contain_service('mesos-slave').with(
      :ensure => 'running',
      :enable => true
    ) }

    it { should contain_service('mesos-master').with(
      :enable => false
    ) }

    it {
      should contain_mesos__service('master').with(:enable => false)
      should contain_mesos__service('slave').with(:enable => true)
    }

    context 'disable single role' do
      let(:params) {{
        :single_role => false,
      }}

      it { should_not contain_service('mesos-master').with(
        :enable => false
      ) }

    end
  end

  context 'systemd support' do
    context 'diable systemd support where systemd is not present' do
      let(:facts) do
        {
          :mesos_version => '0.28.0',
          :osfamily => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'Ubuntu',
          :majdistrelease => '12.04',
          :operatingsystemmajrelease => 'precise',
        }
      end

      it do
        is_expected.to contain_mesos__property('slave_systemd_enable_support')
          .with(
            :ensure => 'present',
            :file => 'systemd_enable_support',
            :value => false,
            :dir => conf,
            :owner => owner,
            :group => group
          )

        is_expected.to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end

    context 'enable systemd support' do
      let(:facts) do
        {
          :mesos_version => '0.28.0',
          :osfamily => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'jessie',
          :operatingsystemmajrelease => '8',
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            :ensure => 'present',
            :file => 'systemd_enable_support',
            :value => true,
            :dir => conf,
            :owner => owner,
            :group => group
          )

        is_expected.not_to contain_file("#{conf}/?systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end

    context 'do not use systemd flag' do
      let(:facts) do
        {
          :mesos_version => '1.0.1',
          :osfamily => 'Debian',
          :operatingsystem => 'Debian',
          :lsbdistcodename => 'jessie',
          :operatingsystemmajrelease => '8',
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            :ensure => 'present',
            :file => 'systemd_enable_support',
            :value => true,
            :dir => conf,
            :owner => owner,
            :group => group
          )

        is_expected.not_to contain_file("#{conf}/?systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end



    context 'do not use systemd_enable_support flag for earlier versions than 0.28' do
      let(:facts) do
        {
          :mesos_version => '0.27.0',
          :osfamily => 'Debian',
          :operatingsystem => 'Ubuntu',
          :lsbdistcodename => 'Ubuntu',
          :operatingsystemmajrelease => 'precise',
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            :ensure => 'present',
            :file => 'systemd_enable_support',
            :value => false,
            :dir => conf,
            :owner => owner,
            :group => group
          )

        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/systemd_enable_support").with_ensure('present')
      end
    end

  end

  context 'auto-detect service provider' do
    let(:facts) do
    {
      :mesos_version => '0.28.2',
      :osfamily => 'RedHat',
      :operatingsystem => 'CentOS',
      :lsbdistcodename => '6.7',
      :operatingsystemmajrelease => '6',
    }
    end

    it { is_expected.to contain_service('mesos-slave').with(
      :ensure => 'running',
      :provider => 'upstart',
      :enable => true
    ) }

    context 'on CentOS 7' do
      let(:facts) do
      {
        :mesos_version => '0.28.2',
        :osfamily => 'RedHat',
        :operatingsystem => 'CentOS',
        :lsbdistcodename => '7',
        :operatingsystemmajrelease => '7',
      }
      end

      it { is_expected.to contain_service('mesos-slave').with(
        :ensure => 'running',
        :provider => 'systemd',
        :enable => true
      ) }
    end
  end

  context 'custom systemd configuration' do
    let(:params) do
      {
        :service_provider    => 'systemd',
        :manage_service_file => true,
        :systemd_after       => 'network-online.target openvpn-client@.service',
        :systemd_wants       => 'network-online.target openvpn-client@.service',
      }
    end

    it do
     is_expected.to contain_service('mesos-slave').with(
        :ensure => 'running',
        :enable => true
      )
    end

    it do
      is_expected.to contain_mesos__service('slave').with(:enable => true)
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service'
      ).with({
        'ensure' => 'present',
      })
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service'
      ).with_content(/Wants=network-online.target openvpn-client@.service/)
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service'
      ).with_content(/After=network-online.target openvpn-client@.service/)
    end

  end

end
