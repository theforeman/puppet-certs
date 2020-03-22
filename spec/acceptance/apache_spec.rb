require 'spec_helper_acceptance'

describe 'certs::apache' do
  context 'with default parameters' do
    let(:pp) do
      'include certs::apache'
    end

    it 'should force regeneration' do
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.update ; fi"
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { should be_installed }
    end
  end

  context 'with server cert' do
    let(:pp) do
      <<-EOS
      class { '::certs::apache':
        server_cert => '/etc/puppetlabs/code/modules/certs/fixtures/example.partial.solutions.crt',
        server_key  => '/etc/puppetlabs/code/modules/certs/fixtures/example.partial.solutions.key',
      }
      EOS
    end

    it 'should force regeneration' do
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.update ; fi"
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', 'CN = Fake LE Intermediate X1'
      include_examples 'certificate subject', 'CN = example.partial.solutions'
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { should be_installed }
    end
  end
end
