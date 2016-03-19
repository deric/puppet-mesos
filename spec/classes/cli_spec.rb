require 'spec_helper'

describe 'mesos::cli', :type => :class do

  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params){{
    :owner    => owner,
    :group    => group,
  }}

  it { should contain_package('python-pip') }
  it { should contain_class('mesos::cli') }
  it { should contain_package('mesos.cli').with({'provider' => 'pip'}) }
  it { should contain_package('mesos.interface').with({'provider' => 'pip'}) }

  context 'set zookeeper url' do
    let(:params) do
      {
        :zookeeper => 'zk://192.168.1.100:2181/mesos',
        :owner     => owner,
        :group     => group,
      }
    end

    it do should contain_file('/etc/.mesos.json').with({
        'ensure'  => 'present',
        'owner'   => owner,
        'group'   => group,
        'mode'    => '0644',
      })
    end

    it do
      should contain_file('/etc/.mesos.json').with_content(
        /zk:\/\/192.168.1.100:2181\/mesos/
      )
    end
  end
end