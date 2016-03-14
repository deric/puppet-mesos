require 'spec_helper'

describe 'mesos::master', :type => :class do
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
    ).with_content(/^export MESOS_IP=/)
  end

  # no zookeeper set by default
  it { should contain_file(file).with_content(/MESOS_ZK=""/) }

  it { should contain_file(file).with_content(/MESOS_PORT=5050/) }

  context 'with zookeeper' do
    let(:params){{
      :zookeeper => [ '192.168.1.100:2181' ],
    }}
    it { should contain_file(
      file).with_content(/^export MESOS_ZK="zk:\/\/192.168.1.100:2181\/mesos"/)
    }
  end

  context 'setting master port' do
    let(:params){{
      :master_port => '4040',
    }}
    it { should contain_file(file).with_content(/^export MESOS_PORT=4040/) }
  end


  it { should contain_file(file).with_content(/CLUSTER="mesos"/) }

  context 'setting cluster name' do
    let(:params){{
      :cluster => 'cluster',
    }}
    it { should contain_file(file).with_content(/^export MESOS_CLUSTER="cluster"/) }
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


    it do
      should contain_file(work_dir).with({
        'ensure'  => 'directory',
        'owner'   => owner,
        'group'   => group,
      })
    end

    it do
      should contain_mesos__property('master_work_dir').with({
        'owner' => owner,
        'group' => group,
        'dir'   => conf,
        'value' => work_dir,
      })
    end

    it do
      should contain_file("#{conf}/work_dir")
        .with_content(work_dir)
        .that_requires("File[#{conf}]")
    end
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

  context 'acls' do
    context 'default w/o acls' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
      } }

      it 'has no acls property' do
        should_not contain_mesos__property(
                       'master_acls'
                   )
      end

      it 'has not acls file' do
        should contain_file(
                   '/etc/mesos/acls'
               )
                   .with({
                             'ensure' => 'absent',
                         })
      end
    end

    context 'w/ acls' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
          :acls => {"some-key" => ["some-value", "some-other-value"]},
      } }

      it 'has acls property' do
        should contain_mesos__property(
                   'master_acls'
               ).with('value' => '/etc/mesos/acls')
      end

      it 'has acls file' do
        should contain_file(
                   '/etc/mesos/acls'
               ).with({
                          'ensure' => 'file',
                          'content' => /{"some-key":\s*\["some-value",\s*"some-other-value"\]}/,
                          'owner' => owner,
                          'group' => group,
                          'mode' => '0444',
                      })
      end
    end
  end

  context 'credentials' do
    context 'default w/o credentials' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
      } }

      it 'has no credentials property' do
        should_not contain_mesos__property(
                       'master_credentials'
                   )
      end

      it 'has not credentials file' do
        should contain_file(
                   '/etc/mesos/master-credentials'
               )
                   .with({
                             'ensure' => 'absent',
                         })
      end
    end

    context 'w/ credentials' do
      let(:params) { {
          :conf_dir => conf,
          :owner => owner,
          :group => group,
          :credentials => [{'principal' => 'some-mesos-principal', 'secret' => 'a-very-secret'}],
      } }

      it 'has credentials property' do
        should contain_mesos__property(
                   'master_credentials'
               ).with({
                          'value' => 'file:///etc/mesos/master-credentials',
                      })
      end

      it 'has credentials file' do
        should contain_file(
                   '/etc/mesos/master-credentials'
               ).with({
                          'ensure' => 'file',
                          'content' => /{"credentials":\s*\[{"principal":\s*"some-mesos-principal",\s*"secret":\s*"a-very-secret"}\]}/,
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
          should contain_mesos__property('master_logger')
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
          should contain_mesos__property('master_logger')
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

  context 'test merging hashes from hiera' do
    let(:params){{
      :use_hiera => true,
    }}

    # quorum defined in spec/fixtures/hiera/test.yaml
    it 'defines quorum' do
      should contain_file("#{conf}/quorum").with_ensure('present')
      should contain_mesos__property('master_quorum')
        .with(:value => 2)
    end
    # advertise_ip defined in spec/fixtures/hiera/default.yaml
    it 'with advertised IP config' do
      should contain_file("#{conf}/advertise_ip").with_ensure('present')
      should contain_mesos__property('master_advertise_ip')
        .with(:value => '10.0.0.1')
    end
  end

  context 'single role' do
    it { should contain_service('mesos-master').with(
      :ensure => 'running',
      :enable => true
    ) }

    it { should contain_service('mesos-slave').with(
      :enable => false
    ) }

    it {
      should contain_mesos__service('master').with(:enable => true)
      should contain_mesos__service('slave').with(:enable => false)
    }

    context 'disable single role' do
      let(:params) {{
        :single_role => false,
      }}

      it { should_not contain_service('mesos-slave').with(
        :enable => false
      ) }

    end
  end


end
