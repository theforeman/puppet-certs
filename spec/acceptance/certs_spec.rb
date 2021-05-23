require 'spec_helper_acceptance'

describe 'certs' do
  context 'with default params' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs' }
    end

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-server-ca.crt') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'SSL server CA' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-default-ca.key') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') }
    end
  end
end
