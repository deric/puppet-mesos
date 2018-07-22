require 'spec_helper'

describe 'mesos', type: :class do
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
      puppetversion: Puppet.version
    }
  end
  context 'with ensure' do
    let(:version) { '0.14' }
    let(:params) do
      {
        ensure: version
      }
    end

    before(:each) do
      puppet_debug_override
    end

    it {
      is_expected.to contain_package('mesos').with(
        'ensure' => version
      )
    }

    it {
      is_expected.not_to contain_package('python').with(
        'ensure' => 'present'
      )
    }
  end

  context 'with given version' do
    let(:version) { '0.20' }
    let(:params) do
      {
        version: version
      }
    end

    it {
      is_expected.to contain_package('mesos').with(
        'ensure' => version
      )
    }
  end

  context 'remove mesos' do
    let(:version) { 'absent' }
    let(:params) do
      {
        ensure: version
      }
    end

    it {
      is_expected.to contain_package('mesos').with(
        'ensure' => version
      )
    }
  end

  context 'specify ulimit' do
    let(:ulimit) { 16_384 }
    let(:file) { '/etc/default/mesos' }
    let(:params) do
      {
        ulimit: ulimit
      }
    end

    it { is_expected.to contain_file(file).with_content(/ULIMIT="-n #{ulimit}"/) }
  end

  it { is_expected.to contain_class('mesos') }
  it { is_expected.to contain_class('mesos::repo') }
  it { is_expected.to contain_class('mesos::install') }
  it { is_expected.to contain_class('mesos::config') }
  it { is_expected.to contain_class('mesos::config').that_requires('Class[mesos::install]') }

  it { is_expected.to compile.with_all_deps }

  context 'change pyton packge name' do
    let(:python) { 'python3' }
    let(:params) do
      {
        manage_python: true,
        python_package: python
      }
    end

    it {
      is_expected.to contain_package(python).with(
        'ensure' => 'present'
      )
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

  context 'remove packaged services' do
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
        puppetversion: Puppet.version
      }
    end

    context 'keeps everything' do
      it {
        is_expected.to contain_class('mesos::install').with(
          'remove_package_services' => false
        )
      }
    end

    context 'remvoes packaged upstart config' do
      let(:params) do
        {
          force_provider: 'none'
        }
      end

      it { is_expected.to contain_class('mesos::install').with('remove_package_services' => true) }
    end
  end

  context 'with zookeeper' do
    let(:params) do
      {
        zookeeper: ['192.168.1.100:2181']
      }
    end
    it {
      is_expected.to contain_file(
        '/etc/mesos/zk'
      ).with(
        ensure: 'present'
      ).with_content(/^zk:\/\/192.168.1.100:2181\/mesos/)
    }
  end

  context 'with manage_zk_file false' do
    let(:params) do
      {
        manage_zk_file: false,
        zookeeper: ['192.168.1.100:2181']
      }
    end
    it {
      is_expected.not_to contain_file(
        '/etc/mesos/zk'
      )
    }
  end

  context 'zookeeper URL - allow passing directly ZooKeeper\'s URI (backward compatibility 0.x)' do
    let(:params) do
      {
        zookeeper: 'zk://192.168.1.100:2181/mesos'
      }
    end
    it {
      is_expected.to contain_file(
        '/etc/mesos/zk'
      ).with(
        ensure: 'present'
      ).with_content(/^zk:\/\/192.168.1.100:2181\/mesos/)
    }
  end

  context 'allow changing zookeeper\'s namespace' do
    let(:params) do
      {
        zookeeper: ['192.168.1.100:2181', '192.168.1.105:2181'],
        zk_path: 'my_mesos'
      }
    end
    it {
      is_expected.to contain_file(
        '/etc/mesos/zk'
      ).with(
        ensure: 'present'
      ).with_content(/^zk:\/\/192.168.1.100:2181,192.168.1.105:2181\/my_mesos/)
    }
  end

  context 'allow changing zookeeper\'s default port' do
    let(:params) do
      {
        zookeeper: ['192.168.1.100', '192.168.1.105'],
        zk_default_port: 2828
      }
    end
    it {
      is_expected.to contain_file(
        '/etc/mesos/zk'
      ).with(
        ensure: 'present'
      ).with_content(/^zk:\/\/192.168.1.100:2828,192.168.1.105:2828\/mesos/)
    }
  end
end
