require 'spec_helper_acceptance'

describe 'certs' do
  fqdn = fact('fqdn')

  keystore_password_file = '/etc/pki/katello/keystore_password-file'
  truststore_password_file = '/etc/pki/katello/truststore_password-file'

  before(:all) do
    on default, 'rm -rf /root/ssl-build'

    manifest = <<~MANIFEST
      file { '/etc/foreman':
        ensure => directory,
      }

      group { 'foreman':
        ensure => present,
        system => true,
      }
    MANIFEST
    apply_manifest(manifest, catch_failures: true)
  end

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

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt") }
    end

    describe file('/etc/pki/katello/certs/katello-tomcat.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/katello-tomcat.key') do
      it { should_not exist }
    end

    describe package("#{fqdn}-tomcat") do
      it { should_not be_installed }
    end

    describe x509_certificate('/etc/foreman/client_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/foreman/client_cert.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman' }
    end

    describe x509_private_key('/etc/foreman/client_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman/client_cert.pem') }
    end

    describe file('/etc/foreman/client_key.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman' }
    end

    describe file('/etc/pki/katello/certs/java_client.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/java_client.key') do
      it { should_not exist }
    end

    describe x509_certificate('/etc/foreman/proxy_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
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
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'tomcat' }
    end

    describe x509_private_key('/etc/candlepin/certs/candlepin-ca.key') do
      it { should_not be_encrypted }
      it { should be_valid }
    end

    describe file('/etc/candlepin/certs/candlepin-ca.key') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
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
      its(:stdout) { should match(/^Owner: CN=#{fqdn}, OU=SomeOrgUnit, O=Katello, ST=North Carolina, C=US$/) }
      its(:stdout) { should match(/^Issuer: CN=#{fqdn}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
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
      its(:stdout) { should match(/^Owner: CN=#{fqdn}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
      its(:stdout) { should match(/^Issuer: CN=#{fqdn}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
    end
  end

  context 'with localhost' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'certs::candlepin':
          hostname => 'localhost',
        }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/localhost/localhost-tomcat.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq('C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = localhost') }
      its(:keylength) { should be >= 4096 }
    end

    describe command("keytool -list -v -keystore /etc/candlepin/certs/keystore -alias tomcat -storepass $(cat #{keystore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Owner: CN=localhost, OU=SomeOrgUnit, O=Katello, ST=North Carolina, C=US$/) }
      its(:stdout) { should match(/^Issuer: CN=#{fqdn}, OU=SomeOrgUnit, O=Katello, L=Raleigh, ST=North Carolina, C=US$/) }
    end
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

      package { 'java-11-openjdk-headless':
        ensure => installed,
      }

      include certs::candlepin
      PUPPET
    end

    it "checks that the fingerprint matches" do
      apply_manifest(pp, catch_failures: true)

      initial_fingerprint_output = on default, 'openssl x509 -noout -fingerprint -sha256 -in /etc/foreman/client_cert.pem'
      initial_fingerprint = initial_fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "keytool -list -keystore /etc/candlepin/certs/truststore -storepass $(cat #{truststore_password_file})"
      expect(initial_truststore_output.output.strip).to include(initial_fingerprint)

      on default, "rm -rf /root/ssl-build/#{fqdn}"
      apply_manifest(pp, catch_failures: true)

      fingerprint_output = on default, 'openssl x509 -noout -fingerprint -sha256 -in /etc/foreman/client_cert.pem'
      fingerprint = fingerprint_output.output.strip.split('=').last
      truststore_output = on default, "keytool -list -keystore /etc/candlepin/certs/truststore -storepass $(cat #{truststore_password_file})"

      expect(truststore_output.output.strip).to include(fingerprint)
      expect(fingerprint).not_to equal(initial_fingerprint)
      expect(truststore_output.output.strip).not_to include(initial_fingerprint)
    end
  end

  context 'updates keystore if the certificate changes' do
    let(:pp) do
      <<-EOS
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
      EOS
    end

    it "checks that the fingerprint matches" do
      apply_manifest(pp, catch_failures: true)

      initial_fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt"
      initial_fingerprint = initial_fingerprint_output.output.strip.split('=').last
      initial_keystore_output = on default, "keytool -list -keystore /etc/candlepin/certs/keystore -storepass $(cat #{keystore_password_file})"
      expect(initial_keystore_output.output.strip).to include(initial_fingerprint)

      on default, "rm -rf /root/ssl-build/#{fqdn}"
      apply_manifest(pp, catch_failures: true)

      fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt"
      fingerprint = fingerprint_output.output.strip.split('=').last
      keystore_output = on default, "keytool -list -keystore /etc/candlepin/certs/keystore -storepass $(cat #{keystore_password_file})"

      expect(keystore_output.output.strip).to include(fingerprint)
      expect(fingerprint).not_to equal(initial_fingerprint)
      expect(keystore_output.output.strip).not_to include(initial_fingerprint)
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/candlepin'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::candlepin':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-tomcat.crt") }
    end

    describe file('/etc/candlepin/certs/keystore') do
      it { should_not exist }
    end

    describe file('/etc/candlepin/certs/truststore') do
      it { should_not exist }
    end

    describe file('/etc/candlepin/certs/candlepin-ca.crt') do
      it { should_not exist }
    end

    describe file('/etc/candlepin/certs/candlepin-ca.key') do
      it { should_not exist }
    end
  end
end
