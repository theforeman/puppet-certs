require 'spec_helper_acceptance'

describe 'certs' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
    source_path = "fixtures/katello-certs-tool-ca/"
    dest_path = "/root/ssl-build/"
    scp_to(hosts, source_path, dest_path)
  end

  context 'with default params' do
    describe x509_certificate('/root/ssl-build/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/root/ssl-build/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/root/ssl-build/katello-default-ca.key') do
      it { should be_encrypted }
    end

    describe file('/root/ssl-build/katello-default-ca.pwd') do
      it { should exist }
    end
  end

  context 'after applying certs should not change CA' do
    before do
      on default, 'cp -rf /root/ssl-build/ /root/ssl-build-backup'
      on default, 'mkdir -p /opt/puppetlabs/puppet/cache/foreman_cache_data'
      on default, 'cp /root/ssl-build/katello-default-ca.pwd /opt/puppetlabs/puppet/cache/foreman_cache_data/ca_key_password'

      @passwd = on(default, 'cat /root/ssl-build-backup/katello-default-ca.pwd').output.strip
      @cert = on(default, 'cat /root/ssl-build-backup/katello-default-ca.crt').output
      @key = on(default, 'cat /root/ssl-build-backup/katello-default-ca.key').output
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs' }
    end

    describe file('/root/ssl-build/katello-default-ca.pwd') do
      its(:content) { should match(@passwd) }
    end

    describe file('/root/ssl-build/katello-default-ca.crt') do
      its(:content) { should match(@cert) }
    end

    describe file('/root/ssl-build/katello-default-ca.key') do
      its(:content) { should match(@key) }
    end
  end
end
