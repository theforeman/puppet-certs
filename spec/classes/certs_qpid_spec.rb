require 'spec_helper'

describe 'certs::qpid' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      let :facts do
        facts
      end

      describe "without parameters" do
        let :pre_condition do
          'include ::certs'
        end

        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_cert('foo.example.com-qpid-broker')
            .with_hostname('foo.example.com')
            .with_cname(['localhost'])
        end

        it { is_expected.to contain_class('certs::ssltools::nssdb') }

        it do
          is_expected.to contain_certs__keypair('qpid')
            .with_key_pair('foo.example.com-qpid-broker')
            .with_key_file('/etc/pki/katello/private/foo.example.com-qpid-broker.key')
            .with_cert_file('/etc/pki/katello/certs/foo.example.com-qpid-broker.crt')
            .with_key_group('qpidd')
        end

        it do
          is_expected.to contain_certs__ssltools__certutil('ca')
            .with_nss_db_dir('/etc/pki/katello/nssdb')
            .with_client_cert('/etc/pki/katello/certs/katello-default-ca.crt')
            .that_subscribes_to('Pubkey[/etc/pki/katello/certs/katello-default-ca.crt]')
        end

        it do
          is_expected.to contain_certs__ssltools__certutil('broker')
            .with_nss_db_dir('/etc/pki/katello/nssdb')
            .with_client_cert('/etc/pki/katello/certs/foo.example.com-qpid-broker.crt')
            .that_subscribes_to('Pubkey[/etc/pki/katello/certs/foo.example.com-qpid-broker.crt]')
        end

        it do
          is_expected.to contain_exec('generate-pfx-for-nss-db')
            .with_command("openssl pkcs12 -in /etc/pki/katello/certs/foo.example.com-qpid-broker.crt -inkey /etc/pki/katello/private/foo.example.com-qpid-broker.key -export -out '/etc/pki/katello/foo.example.com-qpid-broker.pfx' -password 'file:/etc/pki/katello/nssdb/nss_db_password-file'")
        end

        it do
          is_expected.to contain_exec('add-private-key-to-nss-db')
            .with_command("pk12util -i '/etc/pki/katello/foo.example.com-qpid-broker.pfx' -d '/etc/pki/katello/nssdb' -w '/etc/pki/katello/nssdb/nss_db_password-file' -k '/etc/pki/katello/nssdb/nss_db_password-file'")
        end
      end
    end
  end
end
