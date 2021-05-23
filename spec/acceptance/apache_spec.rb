require 'spec_helper_acceptance'

describe 'certs::apache' do
  context 'with default parameters' do
    it 'forces regeneration' do
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.update ; fi"
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::apache' }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { is_expected.to be_installed }
    end
  end

  context 'with server cert' do
    before(:context) do
      %w[crt key].each do |ext|
        source_path = "fixtures/example.partial.solutions.#{ext}"
        dest_path = "/server.#{ext}"
        scp_to(hosts, source_path, dest_path)
      end

      # Force regen
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.update ; fi"
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { '::certs::apache':
          server_cert => '/server.crt',
          server_key  => '/server.key',
        }
        PUPPET
      end
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { is_expected.to be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', 'CN = Fake LE Intermediate X1'
      include_examples 'certificate subject', 'CN = example.partial.solutions'
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { is_expected.to be_installed }
    end
  end
end
