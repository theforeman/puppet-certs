require 'spec_helper_acceptance'

describe 'certs::foreman_proxy' do
  FQDN = fact('fqdn')

  before(:all) do
    manifest = <<~MANIFEST
      file { '/etc/foreman-proxy':
        ensure => directory,
      }

      group { 'foreman-proxy':
        ensure => present,
        system => true,
      }
    MANIFEST
    apply_manifest(manifest, catch_failures: true)
  end

  context 'with default parameters' do
    let(:pp) do
      'include certs::foreman_proxy'
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate('/etc/foreman-proxy/ssl_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = SMART_PROXY, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end

    describe file('/etc/foreman-proxy/ssl_cert.pem') do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/ssl_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman-proxy/ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/ssl_key.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end
  end
end
