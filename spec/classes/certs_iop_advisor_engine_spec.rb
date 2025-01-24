require 'spec_helper'

describe 'certs::iop_advisor_engine' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        it { should compile.with_all_deps }
      end
    end
  end
end
