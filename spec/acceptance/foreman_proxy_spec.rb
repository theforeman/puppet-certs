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
