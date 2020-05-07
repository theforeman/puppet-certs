require 'spec_helper_acceptance'

describe 'certs::mongodb_client' do
  context 'with default parameters' do
    let(:pp) do
      'include certs::mongodb_client'
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate('/etc/pulp/mongodb/mongodb-client-certificate.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pulp/mongodb/mongodb-client-certificate.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pulp/mongodb/mongodb-client-certificate.crt') }
    end

    describe package("mongodb-client-certificate") do
      it { should be_installed }
    end
  end
end
