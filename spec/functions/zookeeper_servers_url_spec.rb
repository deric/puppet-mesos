#! /usr/bin/env ruby -S rspec
require 'spec_helper'
require 'rspec-puppet'

describe 'zookeeper_servers_url' do

  describe 'convert zookeeper servers list to a valid zookeeper url' do
    it 'convert zookeeper server list to zookeeper url only 1 server' do
      param = [ '192.168.1.1:2181' ]

      subject.should run.with_params(param).and_return("zk://192.168.1.1:2181/mesos")
    end

    it 'convert zookeeper server list to zookeeper url with more than 1 server' do
      param = [ '192.168.1.1:2181', '192.168.1.2:2181' ]

      subject.should run.with_params(param).and_return("zk://192.168.1.1:2181,192.168.1.2:2181/mesos")
    end

    it 'should raise an error if run with extra arguments' do
      subject.should run.with_params(1, 2, 3).and_raise_error(Puppet::ParseError)
    end

    it 'should raise an error if the argument is not an array' do
      param = { 'test' => 1 }
      subject.should run.with_params(param).and_raise_error(Puppet::ParseError)
    end

    it 'should be backwards compatible' do
      param = 'zk://192.168.1.1:2181/mesos'

      subject.should run.with_params(param).and_return("zk://192.168.1.1:2181/mesos")
    end

  end

end

