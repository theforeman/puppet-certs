require 'spec_helper_acceptance'

describe 'certs::foreman' do
  FQDN = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build'

    manifest = <<~MANIFEST
      user { 'puppet':
        ensure => present,
        system => true,
      }
    MANIFEST
    apply_manifest(manifest, catch_failures: true)
  end

  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::puppet' }
    end

    describe x509_certificate('/etc/pki/katello/puppet/puppet_client.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/puppet/puppet_client.crt') do
      it { should be_file }
      it { should be_mode 400 }
      it { should be_owned_by 'puppet' }
      it { should be_grouped_into 'root' }
    end

    describe x509_private_key('/etc/pki/katello/puppet/puppet_client.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/puppet/puppet_client.crt') }
    end

    describe file('/etc/pki/katello/puppet/puppet_client.key') do
      it { should be_file }
      it { should be_mode 400 }
      it { should be_owned_by 'puppet' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate('/etc/pki/katello/puppet/puppet_client_ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/puppet/puppet_client_ca.crt') do
      it { should be_file }
      it { should be_mode 400 }
      it { should be_owned_by 'puppet' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-puppet-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{FQDN}/#{FQDN}-puppet-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-puppet-client.crt") }
    end
  end
end
