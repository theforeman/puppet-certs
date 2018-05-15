require 'spec_helper'

describe 'certs::generate_archive' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  context 'for foreman_proxy' do
    let :params do
      {
        certs_tar: '/tmp/tar',
        foreman_proxy: true,
        server_fqdn: 'bar.example.com'
      }
    end

    it do
      should compile.with_all_deps
      should contain_class('certs::foreman_proxy')
    end
  end

  context 'with empty certs_tar' do
    let(:params) { { certs_tar: '' } }

    it do
      should compile.and_raise_error(/\'certs_tar\' expects a String\[1/)
    end
  end

  context 'for foreman_application' do
    let :params do
      {
        certs_tar: '/tmp/tar',
        foreman_application: true,
        server_fqdn: 'bar.example.com'
      }
    end

    it do
      should compile.with_all_deps
      should_not contain_class('certs::foreman_proxy')
    end
  end
end
