require 'spec_helper'

describe 'certs::repomd_gpg' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  context 'without parameters' do
    let :pre_condition do
      'include ::certs'
    end
    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_gpg('repomd_gpg') }
  end
end
