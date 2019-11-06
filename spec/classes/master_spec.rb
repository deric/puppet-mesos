require 'spec_helper'

describe 'mesos::master', type: :class do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos-master' }
  let(:file) { '/etc/default/mesos-master' }

  let(:params) do
    {
      conf_dir: conf,
      owner: owner,
      group: group
    }
  end

  let(:facts) do
    {
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
  it { is_expected.to contain_class('mesos::master') }
  it {
    is_expected.to contain_service('mesos-master').with(
      ensure: 'running',
      enable: true,
    )
  }

  it {
    is_expected.to contain_file(file).with(
      'ensure' => 'present',
      'owner'   => owner,
      'group'   => group,
      'mode'    => '0644',
    )
  }

  it 'shoud not set any IP address by default' do
    is_expected.not_to contain_file(
      file,
    ).with_content(%r{^export MESOS_IP=})
  end

  # no zookeeper set by default
  it { is_expected.not_to contain_file(file).with_content(%r{MESOS_ZK=""}) }

  it { is_expected.to contain_file(file).with_content(%r{MESOS_PORT=5050}) }

  context 'with zookeeper' do
    let(:params) do
      {
        zookeeper: ['192.168.1.100:2181']
      }
    end

    it {
      is_expected.to contain_file(
        file,
      ).with_content(/^export MESOS_ZK="zk:\/\/192.168.1.100:2181\/mesos"/)
    }
  end

  context 'setting master port' do
    let(:params) do
      {
        master_port: 4040
      }
    end

    it { is_expected.to contain_file(file).with_content(%r{^export MESOS_PORT=4040}) }
  end

  it { is_expected.to contain_file(file).with_content(%r{CLUSTER="mesos"}) }

  context 'setting cluster name' do
    let(:params) do
      {
        cluster: 'cluster'
      }
    end

    it { is_expected.to contain_file(file).with_content(%r{^export MESOS_CLUSTER="cluster"}) }
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
        file,
      ).with_content(/export JAVA_HOME="\/usr\/bin\/java"/)
    }

    it {
      is_expected.to contain_file(
        file,
      ).with_content(/export MESOS_HOME="\/var\/lib\/mesos"/)
    }
  end

  context 'disabling service' do
    let(:params) do
      {
        enable: false
      }
    end

    it {
      is_expected.to contain_service('mesos-master').with(
        enable: false,
      )
    }
  end

  context 'changing master config file location' do
    let(:master_file) { '/etc/mesos/master' }
    let(:params) do
      {
        conf_file: master_file
      }
    end

    it {
      is_expected.to contain_file(master_file).with(
        'ensure' => 'present',
        'mode' => '0644',
      )
    }
  end

  context 'set quorum via options' do
    let(:params) do
      {
        conf_dir: conf,
        options: { 'quorum' => 4 }
      }
    end

    it 'has quorum file in master config dir' do
      is_expected.to contain_file(
        "#{conf}/quorum",
      ).with_content(%r{^4$}).with(
        'ensure' => 'present',
      )
    end
  end

  context 'allow changing conf_dir' do
    let(:my_conf_dir) { '/var/mesos-master' }
    let(:params) do
      {
        conf_dir: my_conf_dir,
        options: { 'quorum' => 4 }
      }
    end

    it 'has quorum file in master config dir' do
      is_expected.to contain_file(
        "#{my_conf_dir}/quorum",
      ).with_content(%r{^4$}).with(
        'ensure' => 'present',
      )
    end
  end

  context 'work_dir' do
    let(:work_dir) { '/var/lib/mesos' }
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
      is_expected.to contain_mesos__property('master_work_dir').with(
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

  context 'support boolean flags' do
    let(:my_conf_dir) { '/var/mesos-master' }
    let(:params) do
      {
        conf_dir: my_conf_dir,
        options: { 'authenticate' => true }
      }
    end

    it 'has authenticate file in config dir' do
      is_expected.to contain_file(
        "#{my_conf_dir}/?authenticate",
      ).with(
        'ensure' => 'present',
      )
    end
  end

  context 'nofify service after removing a key' do
    let(:my_conf_dir) { '/tmp/mesos-conf' }
    let(:params) do
      {
        conf_dir: my_conf_dir,
        options: { 'quorum' => 4 }
      }
    end

    before(:each) do
      system("mkdir -p #{my_conf_dir} && touch #{my_conf_dir}/foo")
    end

    after(:each) do
      system("rm -rf #{my_conf_dir}")
    end

    it { is_expected.to contain_service('mesos-master') }
    it { is_expected.to contain_file(my_conf_dir.to_s).that_notifies('Service[mesos-master]') }
  end

  context 'acls' do
    context 'default w/o acls' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group
        }
      end

      it 'has no acls property' do
        is_expected.not_to contain_mesos__property(
          'master_acls',
        )
      end

      it 'has not acls file' do
        is_expected.to contain_file(
          '/etc/mesos/acls',
        )
          .with(
            'ensure' => 'absent',
          )
      end
    end

    context 'w/ acls' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group,
          acls: { 'some-key' => ['some-value', 'some-other-value'] }
        }
      end

      it 'has acls property' do
        is_expected.to contain_mesos__property(
          'master_acls',
        ).with('value' => '/etc/mesos/acls')
      end

      it 'has acls file' do
        is_expected.to contain_file(
          '/etc/mesos/acls',
        ).with(
          'ensure' => 'file',
          'content' => %r{{"some-key":\s*\["some-value",\s*"some-other-value"\]}},
          'owner' => owner,
          'group' => group,
          'mode' => '0444',
        )
      end
    end
  end

  context 'credentials' do
    context 'default w/o credentials' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group
        }
      end

      it 'has no credentials property' do
        is_expected.not_to contain_mesos__property(
          'master_credentials',
        )
      end

      it 'has not credentials file' do
        is_expected.to contain_file(
          '/etc/mesos/master-credentials',
        )
          .with(
            'ensure' => 'absent',
          )
      end
    end

    context 'w/ credentials' do
      let(:params) do
        {
          conf_dir: conf,
          owner: owner,
          group: group,
          credentials: [{ 'principal' => 'some-mesos-principal', 'secret' => 'a-very-secret' }]
        }
      end

      it 'has credentials property' do
        is_expected.to contain_mesos__property(
          'master_credentials',
        ).with(
          'value' => 'file:///etc/mesos/master-credentials',
        )
      end

      it 'has credentials file' do
        is_expected.to contain_file(
          '/etc/mesos/master-credentials',
        ).with(
          'ensure' => 'file',
          'content' => %r{{"credentials":\s*\[{"principal":\s*"some-mesos-principal",\s*"secret":\s*"a-very-secret"}\]}},
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
          is_expected.to contain_mesos__property('master_logger')
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
          is_expected.to contain_mesos__property('master_logger')
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

  context 'test merging hashes from hiera' do
    let(:params) do
      {
        use_hiera: true
      }
    end

    # quorum defined in spec/fixtures/hiera/test.yaml
    it 'defines quorum' do
      is_expected.to contain_file("#{conf}/quorum").with_ensure('present')
      is_expected.to contain_mesos__property('master_quorum')
        .with(value: 2)
    end
    # advertise_ip defined in spec/fixtures/hiera/default.yaml
    it 'with advertised IP config' do
      is_expected.to contain_file("#{conf}/advertise_ip").with_ensure('present')
      is_expected.to contain_mesos__property('master_advertise_ip')
        .with(value: '10.0.0.1')
    end
  end

  context 'single role' do
    it {
      is_expected.to contain_service('mesos-master').with(
        ensure: 'running',
        enable: true,
      )
    }

    it {
      is_expected.to contain_service('mesos-slave').with(
        enable: false,
      )
    }

    it {
      is_expected.to contain_mesos__service('master').with(enable: true)
      is_expected.to contain_mesos__service('slave').with(enable: false)
    }

    context 'disable single role' do
      let(:params) do
        {
          single_role: false
        }
      end

      it {
        is_expected.not_to contain_service('mesos-slave').with(
          enable: false,
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
      is_expected.to contain_service('mesos-master').with(
        ensure: 'running',
        enable: true,
      )
    end

    it do
      is_expected.to contain_mesos__service('master').with(enable: true)
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-master.service',
      ).with(
        'ensure' => 'present',
      )
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-master.service',
      ).with_content(%r{Wants=network-online.target openvpn-client@.service})
    end

    it do
      is_expected.to contain_file(
        '/etc/systemd/system/mesos-master.service',
      ).with_content(%r{After=network-online.target openvpn-client@.service})
    end
  end
end
