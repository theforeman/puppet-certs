require 'spec_helper_acceptance'

describe 'certs::qpid_router::server' do
  fqdn = fact('fqdn')

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
      let(:manifest) { 'include certs::qpid_router::server' }
    end

    describe x509_certificate('/etc/pki/katello/qpid_router_server.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = dispatch server, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:keylength) { should be >= 4096 }
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
      it { should be_mode 440 }
      it { should be_owned_by 'qdrouterd' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-qpid-router-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = dispatch server, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-qpid-router-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-qpid-router-server.crt") }
    end

    describe package("#{fact('fqdn')}-qpid-router-server") do
      it { should_not be_installed }
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/pki/katello'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::qpid_router::server':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-qpid-router-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = dispatch server, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-qpid-router-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-qpid-router-server.crt") }
    end

    describe file('/etc/pki/katello/certs/qpid_router_server.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/qpid_router_server.key') do
      it { should_not exist }
    end

    describe package("#{fact('fqdn')}-qpid-router-server") do
      it { should_not be_installed }
    end
  end
end
