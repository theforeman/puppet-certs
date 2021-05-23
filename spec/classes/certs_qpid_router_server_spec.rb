require 'spec_helper'

describe 'certs::qpid_router::server' do
  on_supported_os.each do |_os, os_facts|
    let :facts do
      os_facts
    end

    describe 'with default parameters' do
      it { is_expected.to compile.with_all_deps }
    end
  end
end
