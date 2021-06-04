require 'spec_helper_acceptance'

describe 'certs::foreman' do
  FQDN = fact('fqdn')

  before(:all) do
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

  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::foreman' }
    end

    describe x509_certificate('/etc/foreman/client_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end

    describe file('/etc/foreman/client_cert.pem') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
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

    describe x509_certificate('/etc/foreman/proxy_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-foreman-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{FQDN}/#{FQDN}-foreman-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-foreman-client.crt") }
    end
  end
end
