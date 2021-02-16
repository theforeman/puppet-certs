require 'spec_helper'

describe 'certs::qpid_router::client' do
  on_supported_os.each do |os, os_facts|
    let :facts do
      os_facts
    end

    describe 'with default parameters' do
      it { should compile.with_all_deps }
    end
  end
end
