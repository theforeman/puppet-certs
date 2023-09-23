require 'spec_helper_acceptance'

describe 'certs' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default params' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs' }
    end

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

    describe x509_certificate('/root/ssl-build/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/root/ssl-build/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/root/ssl-build/katello-default-ca.key') do
      it { should be_encrypted }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.key') do
      it { should_not exist }
    end

    describe package("katello-default-ca") do
      it { should_not be_installed }
    end

    describe package("katello-server-ca") do
      it { should_not be_installed }
    end

    describe file('/root/ssl-build/katello-default-ca.pwd') do
      it { should exist }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.pwd') do
      it { should_not exist }
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/pki/katello'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate('/root/ssl-build/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/root/ssl-build/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/root/ssl-build/katello-default-ca.key') do
      it { should be_encrypted }
    end

    describe file('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.key') do
      it { should_not exist }
    end
  end

  context 'with server CA cert' do
    before(:context) do
      source_path = "fixtures/example.partial.solutions-chain.pem"
      dest_path = "/server-ca.crt"
      scp_to(hosts, source_path, dest_path)
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'certs':
          server_ca_cert => '/server-ca.crt',
        }
        PUPPET
      end
    end

    describe x509_certificate('/root/ssl-build/katello-server-ca.crt') do
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'CA' }
      its(:issuer) { should eq('CN = Fake LE Root X1') }
      its(:subject) { should eq('CN = Fake LE Intermediate X1') }
      its(:keylength) { should be >= 2048 }
    end
  end
end
