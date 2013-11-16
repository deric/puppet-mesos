require 'spec_helper'

describe 'mesos::slave' do
  let(:facts) {{
    :operatingsystem => 'Debian',
    :osfamily => 'Debian',
    :lsbdistcodename => 'wheezy',
  }}

  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params){{
    :conf_dir => '/etc/mesos',
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

  context 'disabling service' do
    let(:params){{
      :enable => false,
    }}

    it { should contain_service('mesos-slave').with(
      :enable => false
    ) }
  end

end
