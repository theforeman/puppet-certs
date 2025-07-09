require 'spec_helper_acceptance'

describe 'certs::iop' do
  fqdn = fact('fqdn')
  hostname = 'localhost'

  before(:all) do
    on default, 'rm -rf /root/ssl-build'

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
      let(:manifest) { 'include certs::iop' }
    end

    describe x509_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{hostname}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-server.crt") }
    end

    describe x509_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL client' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{hostname}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-client.crt") }
    end

    describe file('/etc/iop') do
      it { should_not exist }
    end
  end

  context 'with generate false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::iop':
            generate => false
          }
        PUPPET
      end
    end

    describe file("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-server.crt") do
      it { should_not exist }
    end

    describe file("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-server.key") do
      it { should_not exist }
    end

    describe file("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-client.crt") do
      it { should_not exist }
    end

    describe file("/root/ssl-build/#{hostname}/#{hostname}-iop-core-gateway-client.key") do
      it { should_not exist }
    end

    describe file('/etc/iop') do
      it { should_not exist }
    end
  end
end
