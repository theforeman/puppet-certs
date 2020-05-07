require 'spec_helper'

describe 'certs::qpid_router' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}", if: os_facts[:operatingsystemmajrelease] == '7' do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        it { should compile.with_all_deps }
      end
    end
  end
end
