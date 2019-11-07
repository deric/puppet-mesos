# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'mesos installation', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'basic setup' do
    it 'install mesos-master' do
      pp = <<-EOS
        class{'mesos::master': }
      EOS

      expect(apply_manifest(pp, {
        :catch_failures => false,
        :debug          => false,
        }).exit_code).to be_zero
    end

    describe package('mesos') do
      it { is_expected.to be_installed }
    end

    describe service('mesos-master') do
      it { is_expected.to be_enabled }
      #it { is_expected.to be_running } # might not work due to systemd bug
      # /bin/sh -c systemctl\ is-active\ mesos-master
      # Failed to connect to bus: No such file or directory
    end
  end
end