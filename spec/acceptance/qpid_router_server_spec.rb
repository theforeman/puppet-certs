require 'spec_helper_acceptance'

describe 'certs::qpid_router::server' do
  FQDN = fact('fqdn')

  before(:all) do
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
      let(:manifest) { 'include certs::qpid_router::server' }
    end

    describe x509_certificate('/etc/pki/katello/qpid_router_server.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = dispatch server, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 2048 }
    end

    describe file('/etc/pki/katello/qpid_router_server.crt') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'qdrouterd' }
      it { should be_grouped_into 'root' }
    end

    describe x509_private_key('/etc/pki/katello/qpid_router_server.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/qpid_router_server.crt') }
    end

    describe file('/etc/pki/katello/qpid_router_server.key') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'qdrouterd' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = dispatch server, OU = SomeOrgUnit, CN = #{FQDN}"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{FQDN}/#{FQDN}-qpid-router-server.crt") }
    end
  end
end
