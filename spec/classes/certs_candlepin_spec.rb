require 'spec_helper'

describe 'certs::candlepin' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        it { is_expected.to compile.with_all_deps }

        it { is_expected.to contain_certs__keypair('candlepin-ca') }
        it { is_expected.to contain_pubkey('/etc/candlepin/certs/candlepin-ca.crt').that_comes_before('File[/etc/candlepin/certs/candlepin-ca.crt]') }
        it { is_expected.to contain_file('/etc/candlepin/certs/candlepin-ca.crt') }
        it { is_expected.to contain_privkey('/etc/candlepin/certs/candlepin-ca.key').that_comes_before('File[/etc/candlepin/certs/candlepin-ca.key]') }
        it { is_expected.to contain_file('/etc/candlepin/certs/candlepin-ca.key') }

        it { is_expected.to contain_certs__keypair('tomcat') }
        it { is_expected.to contain_cert('foo.example.com-tomcat').with_ca('Ca[katello-default-ca]') }
        it { is_expected.to contain_privkey('/etc/pki/katello/private/katello-tomcat.key') }
        it { is_expected.to contain_pubkey('/etc/pki/katello/certs/katello-tomcat.crt') }

        it { is_expected.to contain_certs__keypair('candlepin') }
        it { is_expected.to contain_cert('java-client').with_ca('Ca[katello-default-ca]') }
        it { is_expected.to contain_pubkey('/etc/pki/katello/certs/java-client.crt').that_comes_before('File[/etc/pki/katello/certs/java-client.crt]') }
        it { is_expected.to contain_file('/etc/pki/katello/certs/java-client.crt') }
        it { is_expected.to contain_privkey('/etc/pki/katello/private/java-client.key').that_comes_before('File[/etc/pki/katello/private/java-client.key]') }
        it { is_expected.to contain_file('/etc/pki/katello/private/java-client.key') }

        it { is_expected.to contain_file('/etc/candlepin/certs/keystore') }
        it { is_expected.to contain_file('/etc/pki/katello/keystore_password-file') }
        it { is_expected.to contain_exec('candlepin-generate-ssl-keystore').that_notifies('File[/etc/candlepin/certs/keystore]') }

        it { is_expected.to contain_file('/etc/candlepin/certs/truststore') }
        it { is_expected.to contain_file('/etc/pki/katello/truststore_password-file') }
        it do
          is_expected.to contain_truststore_certificate('/etc/candlepin/certs/truststore:candlepin-ca')
            .with_alias('candlepin-ca')
            .with_certificate('/etc/candlepin/certs/candlepin-ca.crt')
            .that_requires('File[/etc/candlepin/certs/candlepin-ca.crt]')
            .with_truststore('/etc/candlepin/certs/truststore')
            .with_password_file('/etc/pki/katello/truststore_password-file')
            .that_requires('File[/etc/pki/katello/truststore_password-file]')
            # TODO: rspec-puppet doesn't support autonotify
            # https://github.com/rodjek/rspec-puppet/pull/819
            #.that_notifies('File[/etc/candlepin/certs/truststore]')
        end

        it do
          is_expected.to contain_truststore_certificate('/etc/candlepin/certs/truststore:artemis-client')
            .with_alias('artemis-client')
            .with_certificate('/etc/pki/katello/certs/java-client.crt')
            .that_requires('File[/etc/pki/katello/certs/java-client.crt]')
            .with_truststore('/etc/candlepin/certs/truststore')
            .with_password_file('/etc/pki/katello/truststore_password-file')
            .that_requires('File[/etc/pki/katello/truststore_password-file]')
            # TODO: rspec-puppet doesn't support autonotify
            # https://github.com/rodjek/rspec-puppet/pull/819
            #.that_notifies('File[/etc/candlepin/certs/truststore]')
        end
      end
    end
  end
end
