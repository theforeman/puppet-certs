require 'spec_helper_acceptance'

describe 'certs with tar archive' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  before(:context) do
    apply_manifest('include certs', catch_failures: true)

    pp = <<-PUPPET
      class { 'certs':
        generate => true,
        deploy   => false,
      }

      class { 'certs::foreman_proxy_content':
        foreman_proxy_fqdn => 'foreman-proxy.example.com',
        certs_tar          => '/root/foreman-proxy.example.com.tar.gz',
      }
    PUPPET

    apply_manifest(pp, catch_failures: true)
    on default, "rm -rf /root/ssl-build"

    install_certs = <<-PUPPET
      class { 'certs':
        tar_file  => '/root/foreman-proxy.example.com.tar.gz',
        generate  => false,
        node_fqdn => 'foreman-proxy.example.com',
      }

      include certs::apache
    PUPPET

    # generation of a certs tar archive and extraction of it are not idempotent by design
    apply_manifest(install_certs, catch_failures: true)
  end

  describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
    it { should be_certificate }
    it { should be_valid }
    it { should have_purpose 'server' }
    include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}"
    include_examples 'certificate subject', "C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = foreman-proxy.example.com"
    its(:keylength) { should be >= 4096 }
  end

  describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
    it { should_not be_encrypted }
    it { should be_valid }
    it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
  end

  describe package("foreman-proxy.example.com-apache") do
    it { should be_installed }
  end
end
