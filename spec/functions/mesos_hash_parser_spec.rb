#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'rspec-puppet'

describe 'mesos_hash_parser' do

  describe 'convert key-value to a puppet resource hash' do
    it 'convert simple hash' do
      param = {
        'isolation' => 'cgroups',
      }

      subject.should run.with_params(param).and_return({
          'isolation' => {
            'value' => 'cgroups',
          }
        })
    end
  end

end