require 'spec_helper'

describe 'mesos' do

  context 'with ensure' do
    let(:version) { '0.14' }
    let(:params) {{
      :ensure => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }
  end

  context 'with given version' do
    let(:version) { '0.20' }
    let(:params) {{
      :version => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }
  end

  context 'remove mesos' do
    let(:version) { 'absent' }
    let(:params) {{
      :ensure => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }
  end
end
