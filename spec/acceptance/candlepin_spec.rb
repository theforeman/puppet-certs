require 'spec_helper_acceptance'

describe 'certs' do
  keystore_password_file = '/etc/pki/katello/keystore_password-file'
  truststore_password_file = '/etc/pki/katello/truststore_password-file'

  context 'with default params' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        user { 'tomcat':
          ensure => present,
        }

        ['/usr/share/tomcat/conf', '/etc/candlepin/certs'].each |$dir| {
          exec { "mkdir -p ${dir}":
            creates => $dir,
            path    => ['/bin', '/usr/bin'],
          }
        }

        package { 'java-11-openjdk-headless':
          ensure => installed,
        }

        include certs::candlepin
        PUPPET
      end
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-tomcat.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-tomcat.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-tomcat.crt') }
    end

    describe x509_certificate('/etc/pki/katello/certs/java-client.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = candlepin, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/java-client.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/java-client.crt') }
    end

    describe file(keystore_password_file) do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'tomcat' }
    end

    describe file(truststore_password_file) do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'tomcat' }
    end

    describe file('/etc/candlepin/certs/keystore') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'tomcat' }
    end

    describe file('/etc/candlepin/certs/truststore') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'tomcat' }
    end

    describe file('/etc/candlepin/certs/candlepin-ca.crt') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'tomcat' }
      it { should be_grouped_into 'tomcat' }
    end

    describe file('/etc/candlepin/certs/candlepin-ca.key') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'tomcat' }
      it { should be_grouped_into 'tomcat' }
    end

    describe command("keytool -list -keystore /etc/candlepin/certs/keystore -storepass $(cat #{keystore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 1 entry$/) }
      its(:stdout) { should match(/^tomcat, .+, PrivateKeyEntry, $/) }
    end

    describe command("keytool -list -v -keystore /etc/candlepin/certs/keystore -alias tomcat -storepass $(cat #{keystore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Owner: CN=#{host_inventory['fqdn']}, OU=SomeOrgUnit, O=Katello, ST=North Carolina, C=US$/) }
      its(:stdout) { should match(/^Issuer: CN=#{host_inventory['fqdn']}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
    end

    describe command("keytool -list -keystore /etc/candlepin/certs/truststore -storepass $(cat #{truststore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 2 entries$/) }
      its(:stdout) { should match(/^candlepin-ca, .+, trustedCertEntry, $/) }
      its(:stdout) { should match(/^artemis-client, .+, trustedCertEntry, $/) }
    end

    describe command("keytool -list -v -keystore /etc/candlepin/certs/truststore -alias candlepin-ca -storepass $(cat #{truststore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Owner: CN=#{host_inventory['fqdn']}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
      its(:stdout) { should match(/^Issuer: CN=#{host_inventory['fqdn']}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
    end
  end

  describe 'with localhost' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'certs::candlepin':
          hostname => 'localhost',
        }
        PUPPET
      end
    end
  end

  describe x509_certificate('/etc/pki/katello/certs/katello-tomcat.crt') do
    it { should be_certificate }
    it { should be_valid }
    it { should have_purpose 'server' }
    include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
    include_examples 'certificate subject', 'C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = localhost'
    its(:keylength) { should be >= 2048 }
  end

  describe x509_certificate('/etc/pki/katello/certs/java-client.crt') do
    it { should be_certificate }
    it { should be_valid }
    it { should have_purpose 'server' }
    include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
    include_examples 'certificate subject', 'C = US, ST = North Carolina, O = candlepin, OU = SomeOrgUnit, CN = localhost'
    its(:keylength) { should be >= 2048 }
  end

  describe command("keytool -list -v -keystore /etc/candlepin/certs/keystore -alias tomcat -storepass $(cat #{keystore_password_file})") do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/^Owner: CN=localhost, OU=SomeOrgUnit, O=Katello, ST=North Carolina, C=US$/) }
    its(:stdout) { should match(/^Issuer: CN=#{host_inventory['fqdn']}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
  end

  context 'updates java-client certificate in truststore if it changes' do
    let(:pp) do
      <<-PUPPET
      user { 'tomcat':
        ensure => present,
      }

      ['/usr/share/tomcat/conf', '/etc/candlepin/certs'].each |$dir| {
        exec { "mkdir -p ${dir}":
          creates => $dir,
          path    => ['/bin', '/usr/bin'],
        }
      }

      package { 'java-1.8.0-openjdk-headless':
        ensure => installed,
      }

      include certs::candlepin
      PUPPET
    end

    it "checks that the fingerprint matches" do
      apply_manifest(pp, catch_failures: true)

      initial_fingerprint_output = on default, 'openssl x509 -noout -fingerprint -sha256 -in /etc/pki/katello/certs/java-client.crt'
      initial_fingerprint = initial_fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "keytool -list -keystore /etc/candlepin/certs/truststore -storepass $(cat #{truststore_password_file})"
      expect(initial_truststore_output.output.strip).to include(initial_fingerprint)

      on default, "rm -rf /root/ssl-build/#{host_inventory['fqdn']}"
      apply_manifest(pp, catch_failures: true)

      fingerprint_output = on default, 'openssl x509 -noout -fingerprint -sha256 -in /etc/pki/katello/certs/java-client.crt'
      fingerprint = fingerprint_output.output.strip.split('=').last
      truststore_output = on default, "keytool -list -keystore /etc/candlepin/certs/truststore -storepass $(cat #{truststore_password_file})"

      expect(truststore_output.output.strip).to include(fingerprint)
      expect(fingerprint).not_to equal(initial_fingerprint)
      expect(truststore_output.output.strip).not_to include(initial_fingerprint)
    end
  end
end
