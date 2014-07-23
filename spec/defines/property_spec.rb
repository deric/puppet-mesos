require 'spec_helper'

describe 'mesos::property' do
  let(:title) { 'some-property' }
  let(:directory) { '/tmp/mesos-conf' }

  let(:params) {{
    :value   => 'foo',
    :dir     => directory,
    :service => '',
  }}

  it 'should create a property file' do
      should contain_file(
        "#{directory}/#{title}"
      ).with_content(/^foo$/).with({
      'ensure'  => 'present',
      })
  end

  context 'with an empty string value' do
    let(:params) {{
      :value   => '',
      :dir     => directory,
      :service => '',
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
      :service => '',
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
      :service => '',
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
      :service => '',
    }}

    it 'should contain a "no-property" file' do
        should contain_file(
          "#{directory}/?no-#{title}"
        ).with({
        'ensure'  => 'present',
        })
    end
  end

  context 'with a numeric value' do
    let(:params) {{
      :value   => 3.14,
      :dir     => directory,
      :service => '',
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