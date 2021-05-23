require 'spec_helper'

describe 'certs::foreman_proxy_content' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        let :params do
          {
            certs_tar: '/tmp/tar',
            foreman_proxy_fqdn: 'bar.example.com'
          }
        end

        it { is_expected.to compile.with_all_deps }
      end

      context 'with empty certs_tar' do
        let(:params) { { certs_tar: '' } }

        it { is_expected.to compile.and_raise_error(%r{\'certs_tar\' expects a Stdlib::Absolutepath}) }
      end
    end
  end
end
