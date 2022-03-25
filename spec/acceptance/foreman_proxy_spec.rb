require 'spec_helper_acceptance'

describe 'certs::foreman_proxy' do
  fqdn = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build'

    manifest = <<~MANIFEST
      file { '/etc/foreman-proxy':
        ensure => directory,
      }

      group { 'foreman-proxy':
        ensure => present,
        system => true,
      }
    MANIFEST
    apply_manifest(manifest, catch_failures: true)
  end

  context 'with default parameters' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs::foreman_proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = SMART_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/foreman-proxy/ssl_cert.pem') do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/ssl_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman-proxy/ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/ssl_key.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_private_key('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman-proxy/foreman_ssl_cert.pem') }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { should be_file }
      it { should be_mode 440 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
    end

    describe x509_certificate('/etc/foreman-proxy/foreman_ssl_ca.pem') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = SMART_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.crt") }
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.crt") }
    end

    describe x509_certificate("/etc/pki/katello/private/#{fqdn}-foreman-proxy-client-bundle.pem") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/etc/pki/katello/private/#{fqdn}-foreman-proxy-client-bundle.pem") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/etc/pki/katello/private/#{fqdn}-foreman-proxy-client-bundle.pem") }
    end

    describe file("/etc/pki/katello/private/#{fqdn}-foreman-proxy-client-bundle.pem") do
      it { should be_file }
      it { should be_mode 444 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'foreman-proxy' }
      its(:content) { should include('BEGIN RSA PRIVATE KEY') }
    end

    describe package("#{fact('fqdn')}-foreman-proxy") do
      it { should_not be_installed }
    end

    describe package("#{fact('fqdn')}-foreman-proxy-client") do
      it { should_not be_installed }
    end
  end

  context 'with server cert' do
    before(:context) do
      ['.crt', '.key', '-chain.pem'].each do |ext|
        source_path = "fixtures/example.partial.solutions#{ext}"
        dest_path = "/server#{ext}"
        scp_to(hosts, source_path, dest_path)
      end

      # Force regen
      on hosts, "if [ -e /root/ssl-build/#{fact('fqdn')} ] ; then touch /root/ssl-build/#{fact('fqdn')}/#{fact('fqdn')}-foreman-proxy.update ; fi"
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        file { '/server-chain.pem':
          ensure => present,
        }

        class { '::certs::foreman_proxy':
          server_ca_cert => '/server-chain.pem',
          server_cert    => '/server.crt',
          server_key     => '/server.key',
        }
        PUPPET
      end
    end

    describe x509_certificate('/etc/foreman-proxy/ssl_cert.pem') do
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'server' }
      its(:issuer) { should eq('CN = Fake LE Intermediate X1') }
      its(:subject) { should eq('CN = example.partial.solutions') }
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/foreman-proxy/ssl_key.pem') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/foreman-proxy/ssl_cert.pem') }
    end

    it do
      foreman_proxy_ca = on default, "cat /etc/foreman-proxy/ssl_ca.pem"
      default_ca = on default, "cat /root/ssl-build/katello-default-ca.crt"
      server_ca = on default, "cat /root/ssl-build/katello-server-ca.crt"

      expect(foreman_proxy_ca.output.strip).to include(default_ca.output.strip)
      expect(foreman_proxy_ca.output.strip).to include(server_ca.output.strip)
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/foreman-proxy'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs::foreman_proxy':
            deploy => false
          }
        PUPPET
      end
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = SMART_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy.crt") }
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should eq("C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}") }
      its(:subject) { should eq("C = US, ST = North Carolina, O = FOREMAN, OU = FOREMAN_PROXY, CN = #{fqdn}") }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-proxy-client.crt") }
    end

    describe file('/etc/foreman-proxy/ssl_cert.pem') do
      it { should_not exist }
    end

    describe file('/etc/foreman-proxy/ssl_key.pem') do
      it { should_not exist }
    end

    describe file('/etc/foreman-proxy/ssl_ca.pem') do
      it { should_not exist }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_cert.pem') do
      it { should_not exist }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_key.pem') do
      it { should_not exist }
    end

    describe file('/etc/foreman-proxy/foreman_ssl_ca.pem') do
      it { should_not exist }
    end

    describe file("/etc/pki/katello/private/#{fqdn}/#{fqdn}-foreman-proxy-client-bundle.pem") do
      it { should_not exist }
    end
  end
end
