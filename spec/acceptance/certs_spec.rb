require 'spec_helper_acceptance'

describe 'certs' do
  context 'with default params' do
    let(:pp) do
      'include certs'
    end

    it_behaves_like 'a idempotent resource'

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-default-ca.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') }
    end
  end
end
