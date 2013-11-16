require 'spec_helper'

describe 'mesos::config' do

  let(:owner) { 'mesos' }
  let(:group) { 'mesos' }

  let(:params){{
    :conf_dir => '/etc/mesos',
    :log_dir  => '/var/log/mesos',
    :owner    => owner,
    :group    => group,
  }}

  it { should contain_file('/etc/default/mesos').with({
    'ensure'  => 'present',
    'owner'   => owner,
    'group'   => group,
    'mode'    => '0644',
    'require' => 'Package[mesos]',
  }) }
end
