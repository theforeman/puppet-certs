require 'spec_helper_acceptance'

describe 'certs::apache' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default parameters' do

    it 'should force regeneration' do
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.update ; fi"
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::apache' }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}") }
      its(:keylength) { should be >= 4096 }
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
    before(:context) do
      ['crt', 'key'].each do |ext|
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
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'server' }
      its(:issuer) { should eq('CN = Fake LE Intermediate X1') }
      its(:subject) { should eq('CN = example.partial.solutions') }
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
