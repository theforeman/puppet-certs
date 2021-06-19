require 'spec_helper_acceptance'

describe 'certs::qpid_router::client' do
  FQDN = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build'

    manifest = <<~MANIFEST
      user { 'qdrouterd':
        ensure => present,
        system => true,
      }
    MANIFEST
    apply_manifest(manifest, catch_failures: true)
  end

  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::qpid_router::client' }
    end

    describe x509_certificate('/etc/pki/katello/qpid_router_client.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = dispatch client, OU = SomeOrgUnit, CN = #{FQDN}") }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/qpid_router_client.crt') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'qdrouterd' }
      it { should be_grouped_into 'root' }
    end

    describe x509_private_key('/etc/pki/katello/qpid_router_client.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/qpid_router_client.crt') }
    end

    describe file('/etc/pki/katello/qpid_router_client.key') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'qdrouterd' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = dispatch client, OU = SomeOrgUnit, CN = #{FQDN}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-client.crt") }
    end
  end
end
