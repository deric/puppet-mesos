require 'spec_helper'

describe 'mesos::cli', :type => :class do

  it { should contain_package('python-pip') }
  it { should contain_package('mesos.cli').with({'provider' => 'pip'}) }
  it { should contain_package('mesos.interface').with({'provider' => 'pip'}) }
end