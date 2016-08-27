require 'spec_helper'

describe 'mesos::repo', :type => :class do

  shared_examples 'debian' do |operatingsystem, lsbdistcodename, puppet|
    let(:params) {{
      :source => 'mesosphere',
    }}

    let(:facts) {{
      :operatingsystem => operatingsystem,
      :osfamily => 'Debian',
      :lsbdistcodename => lsbdistcodename,
      :lsbdistid => operatingsystem,
      :puppetversion => puppet,
    }}

    before(:each) do
      puppet_debug_override
    end

    it { is_expected.to contain_apt__source('mesosphere').with(
     'location' => "http://repos.mesosphere.io/#{operatingsystem.downcase}",
     'repos'    => 'main',
     'release'  => "#{lsbdistcodename}",
     'key'      => {'id' => '81026D0004C44CF7EF55ADF8DF7D54CBE56151BF', 'server' => 'keyserver.ubuntu.com'},
     'include'  => {'src' => false}
    )}

    it { is_expected.to contain_anchor('mesos::repo::begin').that_comes_before('Apt::Source[mesosphere]') }
    it { is_expected.to contain_apt__source('mesosphere').that_comes_before('Class[apt::update]') }
    it { is_expected.to contain_class('apt::update').that_comes_before('Anchor[mesos::repo::end]') }

    context "undef source" do
      let(:params) {{
        :source => 'undef',
      }}
      it { is_expected.not_to contain_apt__source('mesosphere') }
    end
  end

  context 'on Debian based systems' do
    puppet = Puppet.version

    it_behaves_like 'debian', 'Debian', 'wheezy', puppet
    it_behaves_like 'debian', 'Ubuntu', 'precise', puppet
  end

  shared_examples 'redhat' do |operatingsystem, lsbdistcodename, mrel|
    let(:params) {{
      :source => 'mesosphere',
    }}

    let(:osrel) { lsbdistcodename}

    let(:facts) {{
      :operatingsystem => operatingsystem,
      :osfamily                  => 'RedHat',
      :lsbdistcodename           => lsbdistcodename,
      :operatingsystemmajrelease => lsbdistcodename,
      :lsbdistid                 => operatingsystem,
    }}

    it { is_expected.to contain_package('mesosphere-el-repo').with({
     'ensure'   => 'present',
     'provider' => 'rpm',
     'source'   => "http://repos.mesosphere.io/el/#{osrel}/noarch/RPMS/mesosphere-el-repo-#{osrel}-#{mrel}.noarch.rpm",
    })}

    it do is_expected.to contain_exec('yum-clean-expire-cache').with({
        :command => 'yum clean expire-cache',
      })
    end

    context "undef source" do
      let(:params) {{
        :source => 'undef',
      }}
      it { is_expected.not_to contain_package('mesosphere-el-repo') }
    end
  end

  context 'on RedHat based systems' do
    it_behaves_like 'redhat', 'CentOS', '6', '2'
    it_behaves_like 'redhat', 'CentOS', '7', '1'
  end

  # see: https://github.com/deric/puppet-mesos/issues/77
  context 'custom repository' do
    let(:params) do
      {
        'source' => {
          'location' => "http://myrepo.example.com/debian",
          'release'  => 'jessie',
          'repos'    => 'main',
          'key'      => {
            'id'     => '99926D0004C44CF7EF55ADF8DF7D54CBE56151BF',
            'server' => 'keyserver.ubuntu.com',
          },
          'include'  => {
           'src' => false
          },
        }
      }
    end

    let(:facts) {{
      :operatingsystem => 'Debian',
      :osfamily => 'Debian',
      :lsbdistcodename => 'jessie',
      :lsbdistid => 'Debian',
      :puppetversion => Puppet.version,
    }}

    it { is_expected.to contain_apt__source('mesos-custom').with(
     'location' => "http://myrepo.example.com/debian",
     'repos'    => 'main',
     'release'  => 'jessie',
     'key'      => {'id' => '99926D0004C44CF7EF55ADF8DF7D54CBE56151BF', 'server' => 'keyserver.ubuntu.com'},
     'include'  => {'src' => false}
    )}
  end

  context 'allow passing only values different from the default' do
    let(:params) do
      {
        'source' => {
          'key'      => {
            'id'     => '00026D0004C44CF7EF55ADF8DF7D54CBE56151BF',
            'server' => 'keyserver.example.com',
          },
        }
      }
    end
    let(:facts) {{
      :operatingsystem => 'Debian',
      :osfamily => 'Debian',
      :lsbdistcodename => 'jessie',
      :lsbdistid => 'Debian',
      :puppetversion => Puppet.version,
    }}

    it { is_expected.to contain_apt__source('mesos-custom').with(
     'location' => "http://repos.mesosphere.io/debian",
     'repos'    => 'main',
     'release'  => 'jessie',
     'key'      => {'id' => '00026D0004C44CF7EF55ADF8DF7D54CBE56151BF', 'server' => 'keyserver.example.com'},
     'include'  => {'src' => false}
    )}
  end

end
