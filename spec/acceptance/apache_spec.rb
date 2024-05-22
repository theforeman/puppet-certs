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
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe x509_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.crt") }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { should_not be_installed }
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
      its(:issuer) { should match_without_whitespace(/CN = Fake LE Intermediate X1/) }
      its(:subject) { should match_without_whitespace(/CN = example.partial.solutions/) }
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
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
          class { 'certs::apache':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-apache.crt") }
    end

    describe file('/etc/pki/katello/certs/katello-apache.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/katello-apache.key') do
      it { should_not exist }
    end
  end

  context 'with custom certificates fresh' do
    before(:context) do
      ['crt', 'key'].each do |ext|
        source_path = "fixtures/example.partial.solutions.#{ext}"
        dest_path = "/server.#{ext}"
        scp_to(hosts, source_path, dest_path)
      end

      on hosts, 'rm -rf /root/ssl-build'
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
      its(:issuer) { should match_without_whitespace(/CN = Fake LE Intermediate X1/) }
      its(:subject) { should match_without_whitespace(/CN = example.partial.solutions/) }
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe package("#{fact('fqdn')}-apache") do
      it { should_not be_installed }
    end
  end
end
