require 'spec_helper'

describe 'certs::candlepin' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  let :pre_condition do
    "service{'qpidd': }"
  end

  describe 'with default parameters' do
    it { should compile.with_all_deps }
  end
end
