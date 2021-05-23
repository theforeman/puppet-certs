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
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::foreman_proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_cert.pem') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = SMART_PROXY, CN = #{FQDN}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe file('/etc/foreman-proxy/ssl_cert.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 444 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/ssl_key.pem') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate('/etc/foreman-proxy/ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/ssl_key.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 440 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_ca.pem') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{FQDN}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 444 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 440 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_ca.pem') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { is_expected.to be >= 2048 }
    end
  end
end
