require 'spec_helper'

describe 'mesos' do

  context 'with given version' do
    let(:version) { '0.14' }
    let(:params) {{
      :ensure => version
    }}

    it { should contain_package('mesos').with({
      'ensure' => version
    }) }
  end
end
