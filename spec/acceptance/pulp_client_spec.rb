require 'spec_helper_acceptance'

describe 'certs::pulp-client' do
  FQDN = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::pulp_client' }
    end

    describe x509_certificate('/etc/pki/katello/certs/pulp-client.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = PULP, OU = NODES, CN = admin"
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/certs/pulp-client.crt') do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe x509_private_key('/etc/pki/katello/private/pulp-client.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/pulp-client.crt') }
    end

    describe file('/etc/pki/katello/private/pulp-client.key') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe x509_certificate("/root/ssl-build/#{FQDN}/pulp-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{FQDN}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = PULP, OU = NODES, CN = admin"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{FQDN}/pulp-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{FQDN}/pulp-client.crt") }
    end
  end
end
