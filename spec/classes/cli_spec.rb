require 'spec_helper'

describe 'mesos::cli', :type => :class do

  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params){{
    :owner    => owner,
    :group    => group,
    :manage_pip => true,
  }}

  let(:facts) {{
    # still old fact is needed due to this
    # https://github.com/puppetlabs/puppetlabs-apt/blob/master/manifests/params.pp#L3
    :osfamily => 'Debian',
    :os => {
      :family => 'Debian',
      :name => 'Debian',
      :distro => { :codename => 'stretch'},
      :release => { :major => '9', :minor => '1', :full => '9.1' },
    },
    :puppetversion => Puppet.version,
  }}

  before(:each) do
    puppet_debug_override
  end

  it { is_expected.to contain_package('python-pip') }
  it { is_expected.to contain_class('mesos::cli') }
  it { is_expected.to contain_package('mesos.cli').with({'provider' => 'pip'}) }
  it { is_expected.to contain_package('mesos.interface').with({'provider' => 'pip'}) }

  context 'set zookeeper url' do
    let(:params) do
      {
        :zookeeper => 'zk://192.168.1.100:2181/mesos',
        :owner     => owner,
        :group     => group,
      }
    end

    it do is_expected.to contain_file('/etc/.mesos.json').with({
        'ensure'  => 'present',
        'owner'   => owner,
        'group'   => group,
        'mode'    => '0644',
      })
    end

    it do
      is_expected.to contain_file('/etc/.mesos.json').with_content(
        /zk:\/\/192.168.1.100:2181\/mesos/
      )
    end
  end
end
