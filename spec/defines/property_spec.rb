require 'spec_helper'

describe 'mesos::property', :type => :define do
  let(:title) { 'some-property' }
  let(:directory) { '/tmp/mesos-conf' }

  let(:params) {{
    :value   => 'foo',
    :dir     => directory,
    :owner   => 'tester',
    :group   => 'testers',
  }}

  it { should compile }

  it 'should create a property file' do
      should contain_file(
        "#{directory}/#{title}"
      ).with_content(/^foo$/).with({
      'ensure'  => 'present',
      'owner'   => 'tester',
      'group'   => 'testers',
      })
  end

  context 'with an empty string value' do
    let(:params) {{
      :value   => '',
      :dir     => directory,
    }}

    it 'should not contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with({
        'ensure'  => 'absent',
        })
    end
  end

  context 'with an undef value' do
    let(:params) {{
      :value   => :undef,
      :dir     => directory,
    }}

    it 'should not contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with({
        'ensure'  => 'absent',
        })
    end
  end

  context 'with an empty array value' do
    let(:params) {{
      :value   => [], # TODO this is not really meaningful value
      :dir     => directory,
    }}

    it 'should not contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with({
        'ensure'  => 'absent',
        })
    end
  end

  context 'with a boolean (true) value' do
    let(:params) {{
      :value   => true, # TODO this is not really meaningful value
      :dir     => directory,
    }}

    it 'should contain a property file' do
        should contain_file(
          "#{directory}/?#{title}"
        ).with({
        'ensure'  => 'present',
        })
    end
  end

  context 'with a boolean (false) value' do
    let(:params) {{
      :value   => false, # TODO this is not really meaningful value
      :dir     => directory,
    }}

    it 'should contain a "no-property" file' do
        should contain_file(
          "#{directory}/?no-#{title}"
        ).with({
        'ensure'  => 'present',
        })
    end
  end

  context 'with a integer value' do
    let(:params) {{
      :value   => 314,
      :dir     => directory,
    }}

    it 'should contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with_content(/^314$/).with({
      'ensure'  => 'present',
      })
    end
  end

  context 'with a float value' do
    let(:params) {{
      :value   => 3.14,
      :dir     => directory,
    }}

    it 'should contain a property file' do
        should contain_file(
          "#{directory}/#{title}"
        ).with_content(/^3.14$/).with({
      'ensure'  => 'present',
      })
    end
  end
end
