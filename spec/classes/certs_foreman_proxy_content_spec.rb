require 'spec_helper'

describe 'certs::foreman_proxy_content' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  describe 'with default parameters' do
    let :params do
      {
        certs_tar: '/tmp/tar',
        foreman_proxy_fqdn: 'bar.example.com'
      }
    end

    it { should compile.with_all_deps }
  end

  context 'with empty certs_tar' do
    let(:params) { { certs_tar: '' } }

    it { should compile.and_raise_error(/\'certs_tar\' expects a Stdlib::Absolutepath/) }
  end
end
