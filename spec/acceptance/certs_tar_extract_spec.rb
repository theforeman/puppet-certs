require 'spec_helper_acceptance'

describe 'certs with tar archive' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
    on default, 'rm -rf /etc/pki/katello'
  end

  context 'default certificates' do
    before(:context) do
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
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = foreman-proxy.example.com/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end

    describe x509_certificate('/root/ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = Katello, OU = SomeOrgUnit, CN = foreman-proxy.example.com/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key('/root/ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/root/ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.crt') }
    end

    describe package("foreman-proxy.example.com-apache") do
      it { should_not be_installed }
    end

    describe file('/root/ssl-build/foreman-proxy.example.com') do
      it { should be_directory }
    end

    describe file('/root/ssl-build/katello-default-ca.crt') do
      it { should exist }
    end

    describe file('/root/ssl-build/katello-server-ca.crt') do
      it { should exist }
    end
  end

  context 'with custom certificates' do
    before(:context) do
      ['crt', 'key'].each do |ext|
        source_path = "fixtures/example.partial.solutions.#{ext}"
        dest_path = "/server.#{ext}"
        scp_to(hosts, source_path, dest_path)
      end

      source_path = "fixtures/example.partial.solutions-chain.pem"
      dest_path = "/server-ca.crt"
      scp_to(hosts, source_path, dest_path)

      manifest = <<~PUPPET
        class { 'certs':
          server_cert    => '/server.crt',
          server_key     => '/server.key',
          server_ca_cert => '/server-ca.crt',
          generate       => true,
          deploy         => false,
        }

        class { 'certs::foreman_proxy_content':
          foreman_proxy_fqdn => 'foreman-proxy.example.com',
          certs_tar          => '/root/foreman-proxy.example.com.tar.gz',
        }
      PUPPET

      apply_manifest(manifest, catch_failures: true)

      on default, 'rm -rf /root/ssl-build'

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

    describe 'default and server ca certs do not match' do
      it { expect(file('/etc/pki/katello/certs/katello-default-ca.crt').content).not_to eq(file('/etc/pki/katello/certs/katello-server-ca.crt').content) }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_certificate('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      # The issuer and subject are not identical as we only configure it with the intermediate
      # and not the actual root
      its(:issuer) { should match_without_whitespace(/CN = Fake LE Root X1/) }
      its(:subject) { should match_without_whitespace(/CN = Fake LE Intermediate X1/) }
      its(:keylength) { should be >= 2048 }
    end
  end
end
