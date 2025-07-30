require 'spec_helper_acceptance'

describe 'certs::iop_advisor_engine' do
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
      let(:manifest) { 'include certs::iop_advisor_engine' }
    end

    describe x509_certificate('/etc/iop-advisor-engine/server.cert') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{hostname}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/iop-advisor-engine/server.cert') do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe x509_private_key('/etc/iop-advisor-engine/server.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/iop-advisor-engine/server.cert') }
    end

    describe file('/etc/iop-advisor-engine/server.key') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{hostname}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.crt") }
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/iop-advisor-engine'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::iop_advisor_engine':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{hostname}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{hostname}/#{hostname}-iop-advisor-server.crt") }
    end

    describe file('/etc/iop-advisor-engine/server.cert') do
      it { should_not exist }
    end

    describe file('/etc/iop-advisor-engine/server.key') do
      it { should_not exist }
    end
  end

  context 'with generate false and deploy false' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::iop_advisor_engine':
            generate => false,
            deploy => false
          }
        PUPPET
      end
    end

    describe file('/etc/iop-advisor-engine') do
      it { should_not exist }
    end

    describe file('/etc/iop-advisor-engine/server.cert') do
      it { should_not exist }
    end

    describe file('/etc/iop-advisor-engine/server.key') do
      it { should_not exist }
    end
  end
end
