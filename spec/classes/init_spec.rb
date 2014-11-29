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

  context 'specify ulimit' do
    let(:ulimit) { 16384 }
    let(:file) { '/etc/default/mesos' }
    let(:params) {{
      :ulimit => ulimit
    }}

    it { should contain_file(file).with_content(/ULIMIT="-n #{ulimit}"/) }
  end

  it { should contain_class('mesos::config') }
  it { should contain_class('mesos::install') }
  it { should compile.with_all_deps }
end
