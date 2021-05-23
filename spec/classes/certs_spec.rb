require 'spec_helper'

describe 'certs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it { is_expected.to contain_class('certs::install') }
      it { is_expected.to contain_class('certs::config') }
    end
  end
end
