require 'spec_helper'

describe 'mesos::property', type: :define do
  let(:title) { 'some-property' }
  let(:directory) { '/tmp/mesos-conf' }

  let(:facts) do
    {
      mesos_version: '1.2.0',
      osfamily: 'Debian',
      os: {
        family: 'Debian',
        name: 'Debian',
        distro: { codename: 'jessie' },
        release: { major: '8', minor: '9', full: '8.9' }
      },
      path: '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin',
      puppetversion: Puppet.version
    }
  end

  before(:each) do
    puppet_debug_override
  end

  context 'with a string value' do
    let(:params) do
      {
        value: 'foo',
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it do
      parameters = {
        ensure: 'present',
        content: "foo\n"
      }
      is_expected.to contain_file("#{directory}/#{title}").with(parameters)
    end
  end

  context 'with an empty value' do
    let(:params) do
      {
        value: '',
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should remove a property file' do
      is_expected.to contain_file("#{directory}/#{title}").with_ensure('absent')
    end
  end

  context 'with the :undef value' do
    let(:params) do
      {
        value: :undef,
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should remove the property file' do
      is_expected.to contain_file("#{directory}/#{title}").with_ensure('absent')
    end
  end

  context 'without a defined value or dir' do
    let(:params) do
      {}
    end

    it 'should fail with an error' do
      expect do
        is_expected.to compile.with_all_deps
      end.to raise_error /dir/
    end
  end

  context 'with a boolean (true) value' do
    let(:params) do
      {
        value: true,
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should contain a positive "predicate" file' do
      parameters = {
        ensure: 'present',
        content: ''
      }
      is_expected.to contain_file("#{directory}/?#{title}").with(parameters)
    end
  end

  context 'with a boolean (false) value' do
    let(:params) do
      {
        value: false,
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should contain a negative "predicate" file' do
      parameters = {
        ensure: 'present',
        content: ''
      }
      is_expected.to contain_file("#{directory}/?no-#{title}").with(parameters)
    end
  end

  context 'with an integer value' do
    let(:params) do
      {
        value: 123,
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should create a property file with the value' do
      parameters = {
        ensure: 'present',
        content: "123\n"
      }
      is_expected.to contain_file("#{directory}/#{title}").with(parameters)
    end
  end

  context 'with a float value' do
    let(:params) do
      {
        value: 3.14,
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should create a property file with the value' do
      parameters = {
        ensure: 'present',
        content: "3.14\n"
      }
      is_expected.to contain_file("#{directory}/#{title}").with(parameters)
    end
  end

  context 'ensure is set to absent' do
    let(:params) do
      {
        ensure: 'absent',
        value: 'foo',
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should remove a property file' do
      is_expected.to contain_file("#{directory}/#{title}").with_ensure('absent')
    end
  end

  describe 'when ensure is file and the value is empty' do
    let(:params) do
      {
        ensure: 'file',
        value: '',
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it 'should create the property file with an empty value' do
      parameters = {
        ensure: 'present',
        content: "\n"
      }
      is_expected.to contain_file("#{directory}/#{title}").with(parameters)
    end
  end

  describe 'when ensure is directory' do
    let(:params) do
      {
        ensure: 'directory',
        value: 'test',
        dir: directory
      }
    end

    it 'should fail with an error' do
      expect do
        is_expected.to compile.with_all_deps
      end.to raise_error /ensure must be one of/
    end
  end

  context 'file attributes' do
    context 'default' do
      let(:params) do
        {
          ensure: 'present',
          value: 'test',
          dir: directory
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('mesos::params') }

      parameters = {
        owner: 'root',
        group: 'root',
        mode: '0644'
      }

      it { is_expected.to contain_file("#{directory}/#{title}").with(parameters) }

      it { is_expected.not_to contain_mesos__property(title).with(parameters) }
    end

    context 'custom' do
      let(:params) do
        {
          ensure: 'present',
          value: 'test',
          owner: 'user',
          group: 'group',
          mode: '0640',
          dir: directory
        }
      end

      it { is_expected.to compile.with_all_deps }

      it { is_expected.to contain_class('mesos::params') }

      parameters = {
        owner: 'user',
        group: 'group',
        mode: '0640'
      }

      it { is_expected.to contain_file("#{directory}/#{title}").with(parameters) }

      it { is_expected.to contain_mesos__property(title).with(parameters) }
    end
  end

  context 'when the property file is overridden' do
    let(:params) do
      {
        value: 'foo',
        file: 'some-other-property',
        dir: directory
      }
    end

    it { is_expected.to compile.with_all_deps }

    it { is_expected.to contain_mesos__property(title) }

    it do
      parameters = {
        ensure: 'present',
        content: "foo\n"
      }
      is_expected.to contain_file("#{directory}/some-other-property").with(parameters)
    end
  end

  context 'service notification' do
    let(:params) do
      {
        ensure: 'present',
        value: 'test',
        service: 'Service[my-service]',
        dir: directory
      }
    end

    it 'should fail with an error' do
      expect do
        is_expected.to compile.with_all_deps
      end.to raise_error /service is deprecated and will be removed in the next major release/
    end
  end
end
