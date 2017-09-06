#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'rspec-puppet'

describe 'mesos_hash_parser' do

  describe 'convert key-value to a puppet resource hash' do
    it 'convert simple hash' do
      param = {
        'isolation' => 'cgroups',
      }

      is_expected.to run.with_params(param).and_return({
        'isolation' => {
          'value' => 'cgroups',
          'file' => 'isolation',
        }
      })
    end

    it 'should raise an error if run with extra arguments' do
      is_expected.to run.with_params(1, 2, 3, 4).and_raise_error(Puppet::ParseError)
    end

    it 'should raise an error with incorrect type of arguments' do
      is_expected.to run.with_params(1, 2).and_raise_error(Puppet::ParseError)
    end

    it 'should raise an error when running without arguments' do
      is_expected.to run.with_params(nil).and_raise_error(Puppet::ParseError)
    end

    it 'works with simple hash' do
      is_expected.to run.with_params({'foo' => 'bar'}).and_return({
        'foo' => {
          'value' => 'bar',
          'file' => 'foo',
        }
      })
    end
  end

  describe 'support prefixes' do
    it 'should prefix keys' do
      param = {
        'root' => '/cgroups',
      }

    is_expected.to run.with_params(param, 'cg').and_return({
        'cg_root' => {
          'value' => '/cgroups',
          'file' => 'root',
        }
     })
    end

    it 'should prefix files' do
      param = {
        'root' => '/cgroups',
      }

      is_expected.to run.with_params(param, 'cg', 'cg').and_return({
        'cg_root' => {
          'value' => '/cgroups',
          'file' => 'cg_root',
        }
      })
    end
  end

end
