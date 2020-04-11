require 'spec_helper'

describe 'certs::qpid_client' do
  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let :facts do facts end

      describe "with default parameters" do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_cert('foo.example.com-qpid-client-cert')
            .with_hostname('foo.example.com')
            .with_cname([])
        end

        it do
          is_expected.to contain_key_bundle('/etc/pki/pulp/qpid/client.crt')
            .with_key_pair('Cert[foo.example.com-qpid-client-cert]')
        end

        it { is_expected.to contain_file('/etc/pki/pulp/qpid/client.crt') }
      end
    end
  end
end
