require 'spec_helper'

describe 'certs::candlepin' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
      end
    end
  end
end
