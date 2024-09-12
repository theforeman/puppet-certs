require 'spec_helper_acceptance'

describe 'certs' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default params' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) { 'include certs' }
    end

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

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
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.key') do
      it { should_not exist }
    end

    describe package("katello-default-ca") do
      it { should_not be_installed }
    end

    describe package("katello-server-ca") do
      it { should_not be_installed }
    end

    describe file('/root/ssl-build/katello-default-ca.pwd') do
      it { should exist }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.pwd') do
      it { should_not exist }
    end
  end

  context 'with deploy false' do
    before(:context) do
      on default, 'rm -rf /root/ssl-build /etc/pki/katello'
    end

    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
          class { 'certs':
            deploy => false
          }
        PUPPET
      end
    end

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

    describe file('/etc/pki/katello/certs/katello-default-ca.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/certs/katello-server-ca.crt') do
      it { should_not exist }
    end

    describe file('/etc/pki/katello/private/katello-default-ca.key') do
      it { should_not exist }
    end
  end

  context 'with server CA cert' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        class { 'certs':
          server_ca_cert => '/server-ca.crt',
        }
        PUPPET
      end
    end

    describe x509_certificate('/root/ssl-build/katello-server-ca.crt') do
      it { should be_certificate }
      # Doesn't have to be valid - can be expired since it's a static resource
      it { should have_purpose 'CA' }
      its(:issuer) { should match_without_whitespace(/CN = Fake LE Root X1/) }
      its(:subject) { should match_without_whitespace(/CN = Fake LE Intermediate X1/) }
      its(:keylength) { should be >= 2048 }
    end
  end

  context 'with tar file' do
    context 'with default ca' do
      before(:context) do
        manifest = <<~PUPPET
          class { 'certs':
            generate => true,
            deploy   => false,
          }

          class { 'certs::foreman_proxy_content':
            foreman_proxy_fqdn => 'foreman-proxy.example.com',
            certs_tar          => '/root/foreman-proxy.example.com.tar.gz',
          }
        PUPPET

        apply_manifest(manifest, catch_failures: true)

        on default, 'rm -rf /root/ssl-build'
      end

      describe 'deploy certificates' do
        manifest = <<-PUPPET
          class { 'certs':
            tar_file => '/root/foreman-proxy.example.com.tar.gz',
          }
        PUPPET
        # tar extraction is not idempotent
        it { apply_manifest(manifest, catch_failures: true) }
      end

      describe 'default and server ca certs match' do
        it { expect(file('/etc/pki/katello/certs/katello-default-ca.crt').content).to eq(file('/etc/pki/katello/certs/katello-server-ca.crt').content) }
      end

      describe x509_certificate('/etc/pki/katello/certs/katello-default-ca.crt') do
        it { should be_certificate }
        it { should be_valid }
        it { should have_purpose 'SSL server CA' }
        its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
        its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fact('fqdn')}/) }
        its(:keylength) { should be >= 4096 }
      end
    end

    context 'with custom certificates' do
      before(:context) do
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
      end

      describe 'deploy certificates' do
        manifest = <<-PUPPET
          class { 'certs':
            generate => false,
            tar_file => '/root/foreman-proxy.example.com.tar.gz',
          }
        PUPPET
        # tar extraction is not idempotent
        it { apply_manifest(manifest, catch_failures: true) }
      end

      describe 'default and server ca certs match' do
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
        # These don't match since we only configure it with the intermediate
        # and not the actual root
        its(:issuer) { should match_without_whitespace(/CN = Fake LE Root X1/) }
        its(:subject) { should match_without_whitespace(/CN = Fake LE Intermediate X1/) }
        its(:keylength) { should be >= 2048 }
      end
    end
  end
end
