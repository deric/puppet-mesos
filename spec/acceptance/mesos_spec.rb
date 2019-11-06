# frozen_string_literal: true

require 'spec_helper_acceptance'
require 'pry'

describe 'mesos installation', :unless => UNSUPPORTED_PLATFORMS.include?(fact('osfamily')) do
  context 'basic setup' do
    it 'install accounts' do
      pp = <<-EOS
        class{'mesos::master': }
      EOS

      expect(apply_manifest(pp, {
        :catch_failures => false,
        :debug          => false,
        }).exit_code).to be_zero
    end

    describe package('mesos') do
      it { is_expected.to exist }
    end

    context 'second run' do
      it 'applies manifest' do
        expect(apply_manifest(pp,
          :catch_failures => false,
          :debug => true).exit_code).to be_zero
      end
    end
  end
end