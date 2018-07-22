require 'spec_helper'

describe Facter::Util::Fact do
  before do
    Facter.clear
  end

  describe 'mesos_version' do
    context 'returns mesos version when mesos present' do
      it do
        mesos_version_output = 'mesos 0.27.1'
        Facter::Util::Resolution.expects(:which).with('mesos-master').returns('/usr/sbin/mesos-master')
        Facter::Util::Resolution.expects(:exec).with('mesos-master --version 2>&1').returns(mesos_version_output)
        Facter.value(:mesos_version).should == '0.27.1'
      end
    end
  end
end
