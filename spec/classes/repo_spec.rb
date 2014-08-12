require 'spec_helper'

describe 'mesos::repo' do

  shared_examples 'debian' do |operatingsystem, lsbdistcodename|
    let(:params) {{
      :source => 'mesosphere',
    }}

    let(:facts) {{
      :operatingsystem => operatingsystem,
      :osfamily => 'Debian',
      :lsbdistcodename => lsbdistcodename,
      :lsbdistid => operatingsystem,
    }}

    it { should contain_apt__source('mesosphere').with(
     'location'   => "http://repos.mesosphere.io/#{operatingsystem.downcase}",
     'repos'      => 'main',
     'release'    => "#{lsbdistcodename}",
     'key'        => 'E56151BF',
     'key_server' => 'keyserver.ubuntu.com',
    )}

    it { should contain_class('apt') }

    context "undef source" do
      let(:params) {{
        :source => 'undef',
      }}
      it { should_not contain_apt__source('mesosphere') }
    end
  end

  context 'on Debian based systems' do
    it_behaves_like 'debian', 'Debian', 'wheezy'
    it_behaves_like 'debian', 'Ubuntu', 'precise'
  end

end