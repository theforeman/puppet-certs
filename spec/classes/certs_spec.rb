require 'spec_helper'

describe 'certs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      it { should contain_class('certs::install') }
      it { should contain_class('certs::config::generate') }
    end
  end
end
