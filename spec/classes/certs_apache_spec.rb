require 'spec_helper'

describe 'certs::apache' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  describe 'with default parameters' do
    it { should compile.with_all_deps }
  end

  describe "with group overridden" do
    let :pre_condition do
      "class {'certs': group => 'foreman',}"
    end

    it { should compile.with_all_deps }

    it do
      is_expected.to contain_certs__keypair('apache')
        .with_key_group('foreman')
    end
  end
end
