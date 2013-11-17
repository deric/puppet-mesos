require 'spec_helper'

describe 'mesos::slave' do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos' }

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
    'require' => 'Package[mesos]',
  }) }

  it 'has ip address from system fact' do
    should contain_file(
      '/etc/mesos/slave.conf'
    ).with_content(/IP="192.168.1.1"/)
  end

  context 'one master node' do
    let(:params){{
      :master => '192.168.1.100',
    }}
    it { should contain_file(
      '/etc/mesos/slave.conf'
      ).with_content(/MASTER="192.168.1.100:5050"/)
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

end
