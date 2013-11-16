require 'spec_helper'

describe 'mesos::master' do
  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }
  let(:conf) { '/etc/mesos' }

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

  it { should contain_file('/etc/mesos/master.conf').with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
  }) }

  context 'disabling service' do
    let(:params){{
      :enable => false,
    }}

    it { should contain_service('mesos-master').with(
      :enable => false
    ) }
  end

end
