require 'spec_helper'

describe 'mesos::install' do

  context 'with given version' do
    let(:version) { '0.14' }
    let(:params) {{
      :ensure => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }

    # mesos dependencies (for web GUI)
    it { should contain_package('python').with({
      'ensure' => 'present'
    }) }

    it { should contain_class('mesos::repo') }
    it { should contain_package('python') }
  end

  context 'do not manage python' do
    let(:params){{
        :manage_python => false,
      }}
    it { should_not contain_package('python') }
  end
end
