require 'spec_helper'

describe 'certs::qpid' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe "with default parameters" do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_cert('foo.example.com-qpid-broker')
            .with_hostname('foo.example.com')
            .with_cname(['localhost'])
        end

        it { is_expected.to contain_class('certs::ssltools::nssdb') }

        it do
          is_expected.to contain_nssdb_certificate('/etc/pki/katello/nssdb:ca')
            .with_ensure('present')
            .with_certificate('/etc/pki/katello/certs/katello-default-ca.crt')
            .with_trustargs('TCu,Cu,Tuw')
            .with_password_file('/etc/pki/katello/nss_db_password-file')
        end

        it do
          is_expected.to contain_nssdb_certificate('/etc/pki/katello/nssdb:broker')
            .with_ensure('present')
            .with_certificate('/root/ssl-build/foo.example.com/foo.example.com-qpid-broker.crt')
            .with_private_key('/root/ssl-build/foo.example.com/foo.example.com-qpid-broker.key')
            .with_trustargs(',,')
            .with_password_file('/etc/pki/katello/nss_db_password-file')
        end
      end
    end
  end
end
