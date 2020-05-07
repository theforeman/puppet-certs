require 'spec_helper'

describe 'certs::mongodb_client' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  describe 'with default parameters' do
    it { should compile.with_all_deps }
  end
end
