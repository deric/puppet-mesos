require 'spec_helper'

describe 'mesos::slave', type: :class do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos-slave' }
  let(:slave_file) { '/etc/default/mesos-slave' }

  let(:params) do
    {
      conf_dir: conf,
      owner: owner,
      group: group
    }
  end

  let(:facts) do
    {
      mesos_version: '1.2.0',
      # still old fact is needed due to this
      # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
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

  before(:each) do
    puppet_debug_override
  end

  it { is_expected.to contain_package('mesos') }
  it {
    is_expected.to contain_service('mesos-slave').with(
      ensure: 'running',
      enable: true,
    )
  }

  it {
    is_expected.to contain_file(slave_file).with(
      'ensure' => 'present',
      'owner'   => owner,
      'group'   => group,
      'mode'    => '0644',
    )
  }

  it 'does not set IP address by default' do
    is_expected.not_to contain_file(
      slave_file,
    ).with_content(%r{^export MESOS_IP=})
  end

  context 'with ip address set' do
    let(:params) do
      {
        listen_address: '192.168.1.1'
      }
    end

    it 'has ip address from param' do
      is_expected.to contain_file(
        slave_file,
      ).with_content(%r{^export MESOS_IP="192.168.1.1"$})
    end
  end

  it 'has default port eq to 5051' do
    is_expected.to contain_file(
      slave_file,
    ).with_content(%r{^export MESOS_PORT=5051$})
  end

  it 'checkpoint should be false' do
    is_expected.not_to contain_file(
      "#{conf}/?checkpoint",
    ).with(
      'ensure' => 'present',
    )
  end

  it 'has workdir in /var/lib/mesos' do
    is_expected.to contain_file(
      "#{conf}/work_dir",
    ).with_content(/^\/var\/lib\/mesos$/)
  end

  context 'one master node' do
    let(:params) do
      {
        master: '192.168.1.100'
      }
    end

    it {
      is_expected.to contain_file(
        slave_file,
      ).with_content(%r{^export MESOS_MASTER="192.168.1.100:5050"})
    }
    it {
      is_expected.to contain_file(
        '/etc/mesos/zk',
      ).with(ensure: 'absent')
    }
  end

  context 'zookeeper should be preferred before single master' do
    let(:params) do
      {
        master: '172.16.0.1',
        zookeeper: ['192.168.1.100:2181']
      }
    end

    it {
      is_expected.not_to contain_file(
        slave_file,
      ).with_content(%r{^export MESOS_MASTER="172.16.0.1"})
    }
    # this would work only if we set mesos::zookeeper through hiera
    # it { should contain_file(
    #  '/etc/mesos/zk'
    #  ).with_content(/^zk:\/\/192.168.1.100:2181\/mesos/)
    # }
  end

  context 'disabling service' do
    let(:params) do
      {
        enable: false
      }
    end

    it {
      is_expected.to contain_service('mesos-slave').with(
        enable: false,
      )
    }
  end

  context 'changing workdir' do
    let(:params) do
      {
        work_dir: '/home/mesos'
      }
    end

    it {
      is_expected.to contain_file(
        "#{conf}/work_dir",
      ).with_content(/^\/home\/mesos$/)
    }
  end

  context 'enabling checkpoint (enabled by default anyway)' do
    let(:params) do
      {
        options: {
          'checkpoint' => true
        }
      }
    end

    it {
      is_expected.to contain_file(
        "#{conf}/?checkpoint",
      ).with(
        'ensure' => 'present',
      )
    }
  end

  context 'disabling checkpoint' do
    let(:params) do
      {
        options: {
          'checkpoint' => false
        }
      }
    end

    it {
      is_expected.to contain_file(
        "#{conf}/?no-checkpoint",
      ).with(
        'ensure' => 'present',
      )
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
        slave_file,
      ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/)
    }

    it {
      is_expected.to contain_file(
        slave_file,
      ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/)
    }
  end

  it 'does not set isolation by default (value depends on mesos version)' do
    is_expected.not_to contain_file(
      "#{conf}/isolation",
    ).with(
      'ensure' => 'present',
    )
  end

  context 'should set isolation to cgroups' do
    let(:params)  do
      {
        isolation: 'cgroups/cpu,cgroups/mem'
      }
    end

    it {
      is_expected.to contain_file(
        "#{conf}/isolation",
      ).with(
        'ensure' => 'present',
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    }
  end

  it 'does not contain cgroups settings' do
    is_expected.not_to contain_file(
      slave_file,
    ).with_content(%r{CGROUPS})
  end

  context 'setting isolation mechanism' do
    let(:params) do
      {
        isolation: 'cgroups/cpu,cgroups/mem',
        cgroups: {
          'hierarchy' => '/sys/fs/cgroup',
          'root' => 'mesos'
        },
        owner: owner,
        group: group
      }
    end

    it {
      is_expected.to contain_file(
        "#{conf}/cgroups_root",
      ).with_content(%r{^mesos$})
    }

    it {
      is_expected.to contain_file(
        "#{conf}/cgroups_hierarchy",
      ).with_content(/^\/sys\/fs\/cgroup$/)
    }

    it {
      is_expected.to contain_file(
        "#{conf}/isolation",
      ).with(
        'ensure' => 'present',
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    }

    it {
      is_expected.to contain_mesos__property('slave_hierarchy').with(
        'owner' => owner,
        'group'   => group,
        'dir'     => conf,
        'value'   => '/sys/fs/cgroup',
      )
    }
  end

  context 'changing slave config file location' do
    let(:slave_file) { '/etc/mesos/slave' }
    let(:params) do
      {
        conf_file: slave_file
      }
    end

    it {
      is_expected.to contain_file(slave_file).with(
        'ensure' => 'present',
        'mode' => '0644',
      )
    }
  end

  context 'resources specification' do
    let(:resources_dir) { '/etc/mesos-slave/resources' }

    let(:params) do
      {
        resources: {
          'cpu' => '4',
          'mem' => '2048'
        }
      }
    end

    it {
      is_expected.to contain_file(resources_dir).with(
        'ensure' => 'directory',
      )
    }

    it {
      is_expected.to contain_file(
        "#{resources_dir}/cpu",
      ).with_content(%r{^4$})
    }

    it {
      is_expected.to contain_file(
        "#{resources_dir}/mem",
      ).with_content(%r{^2048$})
    }
  end

  context 'custom listen_address value' do
    let(:params)  do
      {
        conf_dir: conf,
        owner: owner,
        group: group,
        listen_address: '192.168.1.2'
      }
    end

    # fact is not evaluated in test with newer puppet (or rspec)
    it 'has ip address from system fact' do
      is_expected.to contain_file(
        slave_file,
      ).with_content(%r{IP="192\.168\.1\.2"$})
    end
  end

  context 'set isolation via options' do
    let(:params) do
      {
        conf_dir: conf,
        options: { 'isolation' => 'cgroups/cpu,cgroups/mem' }
      }
    end

    it 'contains isolation file in slave directory' do
      is_expected.to contain_file(
        "#{conf}/isolation",
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    end
  end

  context 'allow changing config directory' do
    let(:my_conf_dir) { '/var/mesos-slave' }
    let(:params) do
      {
        conf_dir: my_conf_dir,
        options: { 'isolation' => 'cgroups/cpu,cgroups/mem' }
      }
    end

    it 'contains isolation file in slave directory' do
      is_expected.to contain_file(
        "#{my_conf_dir}/isolation",
      ).with_content(/^cgroups\/cpu,cgroups\/mem$/)
    end
  end

  context 'work_dir' do
    let(:work_dir) { '/tmp/mesos' }
    let(:params) do
      {
        conf_dir: conf,
        work_dir: work_dir,
        owner: owner,
        group: group
      }
    end

    it do
      is_expected.to contain_file(work_dir).with(
        'ensure' => 'directory',
        'owner'   => owner,
        'group'   => group,
      )
    end

    it do
      is_expected.to contain_mesos__property('slave_work_dir').with(
        'owner' => owner,
        'group' => group,
        'dir'   => conf,
        'value' => work_dir,
      )
    end

    it do
      is_expected.to contain_file("#{conf}/work_dir")
        .with_content(work_dir + "\n")
        .that_requires("File[#{conf}]")
    end
  end

  context 'common slave config' do
    let(:params)  do
      {
        zookeeper: 'zk://192.168.1.1:2181,192.168.1.2:2181,192.168.1.3:2181/mesos',
        listen_address: '192.168.1.1',
        attributes: {
          'env' => 'production'
        },
        resources: {
          'ports' => '[10000-65535]'
        }
      }
    end

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_package('mesos') }
    it {
      is_expected.to contain_service('mesos-slave').with(
        ensure: 'running',
        enable: true,
      )
    }

    it {
      is_expected.to contain_mesos__property('resources_ports').with(
        'dir' => '/etc/mesos-slave/resources',
        'file'    => 'ports',
        'value'   => '[10000-65535]',
      )
    }

    it {
      is_expected.to contain_mesos__property('attributes_env').with(
        'dir' => '/etc/mesos-slave/attributes',
        'file'    => 'env',
        'value'   => 'production',
      )
    }
  end

  context 'support boolean flags' do
    let(:my_conf_dir) { '/var/mesos-slave' }
    let(:params) do
      {
        conf_dir: my_conf_dir,
        options: { 'strict' => false }
      }
    end

    it 'has no-strict file in config dir' do
      is_expected.to contain_file(
        "#{my_conf_dir}/?no-strict",
      ).with(
        'ensure' => 'present',
      )
    end
  end

  context 'nofify service after removing a key' do
    let(:my_conf_dir) { '/tmp/mesos-conf' }
    let(:params) do
      {
        conf_dir: my_conf_dir
      }
    end

    before(:each) do
      system("mkdir -p #{my_conf_dir} && touch #{my_conf_dir}/foo")
    end

    after(:each) do
      system("rm -rf #{my_conf_dir}")
    end

    it { is_expected.to contain_service('mesos-slave') }
    it { is_expected.to contain_file(my_conf_dir.to_s).that_notifies('Service[mesos-slave]') }
  end

  context 'nofify service after removing a key' do
    let(:my_conf_dir) { '/tmp/mesos-conf' }
    let(:params) do
      {
        conf_dir: my_conf_dir
      }
    end

    before(:each) do
      system("mkdir -p #{my_conf_dir}/resources && echo 2 > #{my_conf_dir}/resources/cpus")
    end

    after(:each) do
      system("rm -rf #{my_conf_dir}")
    end

    it { is_expected.to contain_service('mesos-slave') }
    it { is_expected.to contain_file(my_conf_dir.to_s).that_notifies('Service[mesos-slave]') }
  end

  context 'credentials' do
    context 'default w/o principal/secret' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group
        }
      end

      it 'has no credentials property' do
        is_expected.not_to contain_mesos__property(
          'slave_credential',
        )
      end

      it 'has not credentials file' do
        is_expected.to contain_file(
          '/etc/mesos/slave-credentials',
        )
          .with(
            'ensure' => 'absent',
          )
      end
    end

    context 'w/ principal/secret' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group,
          principal: 'some-mesos-principal',
          secret: 'a-very-secret'
        }
      end

      it 'has credentials property' do
        is_expected.to contain_mesos__property(
          'slave_credential',
        ).with(
          'value' => '/etc/mesos/slave-credentials',
        )
      end

      it 'has credentials file' do
        is_expected.to contain_file(
          '/etc/mesos/slave-credentials',
        ).with(
          'ensure' => 'file',
          'content' => '{"principal": "some-mesos-principal", "secret": "a-very-secret"}',
          'owner' => owner,
          'group' => group,
          'mode' => '0400',
        )
      end
    end

    context 'syslog logger' do
      describe 'when syslog_logger is true' do
        let(:params) do
          {
            conf_dir: conf,
            owner: owner,
            group: group,
            syslog_logger: true
          }
        end

        it do
          is_expected.to contain_mesos__property('slave_logger')
            .with(
              ensure: 'absent',
              file: 'logger',
              value: false,
              dir: conf,
              owner: owner,
              group: group,
            )

          is_expected.to contain_file("#{conf}/?no-logger").with_ensure('absent')
        end
      end

      describe 'when syslog_logger is false' do
        let(:params) do
          {
            conf_dir: conf,
            owner: owner,
            group: group,
            syslog_logger: false
          }
        end

        it do
          is_expected.to contain_mesos__property('slave_logger')
            .with(
              ensure: 'present',
              file: 'logger',
              value: false,
              dir: conf,
              owner: owner,
              group: group,
            )

          is_expected.to contain_file("#{conf}/?no-logger").with_ensure('present')
        end
      end
    end
  end

  context 'single role' do
    it {
      is_expected.to contain_service('mesos-slave').with(
        ensure: 'running',
        enable: true,
      )
    }

    it {
      is_expected.to contain_service('mesos-master').with(
        enable: false,
      )
    }

    it {
      is_expected.to contain_mesos__service('master').with(enable: false)
      is_expected.to contain_mesos__service('slave').with(enable: true)
    }

    context 'disable single role' do
      let(:params) do
        {
          single_role: false
        }
      end

      it {
        is_expected.not_to contain_service('mesos-master').with(
          enable: false,
        )
      }
    end
  end

  context 'systemd support' do
    context 'diable systemd support where systemd is not present' do
      let(:facts) do
        {
          mesos_version: '1.2.0',
          # still old fact is needed due to this
          # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            name: 'Debian',
            distro: { codename: 'precise' },
            release: { major: '12', minor: '04', full: '12.04' }
          },
          path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          puppetversion: Puppet.version
        }
      end

      it do
        is_expected.to contain_mesos__property('slave_systemd_enable_support')
          .with(
            ensure: 'present',
            file: 'systemd_enable_support',
            value: false,
            dir: conf,
            owner: owner,
            group: group,
          )

        is_expected.to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end

    context 'enable systemd support' do
      let(:facts) do
        {
          mesos_version: '1.2.0',
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            name: 'Debian',
            distro: { codename: 'jessie' },
            release: { major: '8', minor: '9', full: '8.9' }
          },
          path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          puppetversion: Puppet.version
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            ensure: 'present',
            file: 'systemd_enable_support',
            value: true,
            dir: conf,
            owner: owner,
            group: group,
          )

        is_expected.not_to contain_file("#{conf}/?systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end

    context 'do not use systemd flag' do
      let(:facts) do
        {
          mesos_version: '1.2.0',
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            name: 'Debian',
            distro: { codename: 'jessie' },
            release: { major: '8', minor: '9', full: '8.9' }
          },
          path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          puppetversion: Puppet.version
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            ensure: 'present',
            file: 'systemd_enable_support',
            value: true,
            dir: conf,
            owner: owner,
            group: group,
          )

        is_expected.not_to contain_file("#{conf}/?systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
      end
    end

    context 'do not use systemd_enable_support flag for earlier versions than 0.28' do
      let(:facts) do
        {
          mesos_version: '0.27.0',
          osfamily: 'Debian',
          os: {
            family: 'Debian',
            name: 'Debian',
            distro: { codename: 'jessie' },
            release: { major: '8', minor: '9', full: '8.9' }
          },
          path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
          puppetversion: Puppet.version
        }
      end

      it do
        is_expected.not_to contain_mesos__property('slave_systemd_enable_support')
          .with(
            ensure: 'present',
            file: 'systemd_enable_support',
            value: false,
            dir: conf,
            owner: owner,
            group: group,
          )

        is_expected.not_to contain_file("#{conf}/?no-systemd_enable_support").with_ensure('present')
        is_expected.not_to contain_file("#{conf}/systemd_enable_support").with_ensure('present')
      end
    end
  end

  context 'auto-detect service provider' do
    let(:facts) do
      {
        mesos_version: '1.2.0',
        osfamily: 'RedHat',
        os: {
          family: 'RedHat',
          name: 'CentOS',
          release: { major: '6', minor: '7', full: '6.7' }
        }
      }
    end

    it {
      is_expected.to contain_service('mesos-slave').with(
        ensure: 'running',
        provider: 'upstart',
        enable: true,
      )
    }

    context 'on CentOS 7' do
      let(:facts) do
        {
          mesos_version: '1.2.0',
          osfamily: 'RedHat',
          os: {
            family: 'RedHat',
            name: 'CentOS',
            release: { major: '7', minor: '7', full: '7.7' }
          }
        }
      end

      it {
        is_expected.to contain_service('mesos-slave').with(
          ensure: 'running',
          provider: 'systemd',
          enable: true,
        )
      }
    end
  end

  context 'custom systemd configuration' do
    let(:params) do
      {
        service_provider: 'systemd',
        manage_service_file: true,
        systemd_after: 'network-online.target openvpn-client@.service',
        systemd_wants: 'network-online.target openvpn-client@.service'
      }
    end

    it do
      is_expected.to contain_service('mesos-slave').with(
        ensure: 'running',
        enable: true,
      )
    end

    it do
      is_expected.to contain_mesos__service('slave').with(enable: true)
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service',
      ).with(
        'ensure' => 'present',
      )
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service',
      ).with_content(%r{Wants=network-online.target openvpn-client@.service})
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-slave.service',
      ).with_content(%r{After=network-online.target openvpn-client@.service})
    end
  end
end
