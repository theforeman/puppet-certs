require 'spec_helper_acceptance'

describe 'certs with default params' do
  context 'with default params' do
    let(:pp) do
      <<-EOS
      $repo = 'latest'
      $dist = 'el7'

      package { 'epel-release':
        ensure => installed,
      }

      yumrepo { 'katello':
        descr    => 'Katello latest',
        baseurl  => "https://fedorapeople.org/groups/katello/releases/yum/${repo}/katello/${dist}/\\$basearch/",
        gpgkey   => 'https://raw.githubusercontent.com/Katello/katello-packaging/master/repos/RPM-GPG-KEY-katello-2015',
        gpgcheck => '0',
        enabled  => '1',
      }
      class { '::certs':}
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
      its(:subject) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
      its(:subject) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
    end
  end

  context 'with custom server certs' do
    before(:all) do
      beforepp = <<-EOS
        # Mark server-ca for update
        file { '/root/ssl-build/katello-server-ca.update':
          ensure => file,
        }

        Exec {
          path => ['/usr/bin'],
        }

        file { '/root/custom_cert':
          ensure => directory,
        } ~>
        exec { 'Create CA key':
          cwd     => "/root/custom_cert",
          command => "openssl genrsa -out ca.key 2048",
          creates => "/root/custom_cert/ca.key",
        } ~>
        exec { 'Create CA certficates':
          cwd     => "/root/custom_cert",
          command => 'openssl req -new -x509 -key ca.key -out ca.crt -nodes -x509 -subj "/C=US/ST=North Carolina/L=Raleigh/O=CustomKatelloCA/CN=www.custom-katello-ca.example.com"',
          creates => "/root/custom_cert/ca.crt",
        } ~>
        exec { 'Create custom key':
          cwd     => "/root/custom_cert",
          command => "openssl genrsa -out katello.example.com.key 2048",
          creates => "/root/custom_cert/katello.example.com.key",
        } ~>
        exec { 'Create CSR':
          cwd     => "/root/custom_cert",
          command => 'openssl req -new -key katello.example.com.key -out katello.example.com.csr -nodes -subj  "/C=US/ST=North Carolina/L=Raleigh/O=Katello/CN=www.katello.example.com"',
          creates => "/root/custom_cert/katello.example.com.csr",
        } ~>
        exec { 'Sign CSR':
          cwd     => "/root/custom_cert",
          command => 'openssl x509 -req -in katello.example.com.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out katello.example.com.crt',
          creates => "/root/custom_cert/katello.example.com.crt",
        } 
      EOS
      apply_manifest(beforepp)
    end

    let(:pp) do
      <<-EOS
      $repo = 'latest'
      $dist = 'el7'

      package { 'epel-release':
        ensure => installed,
      }

      yumrepo { 'katello':
        descr    => 'Katello latest',
        baseurl  => "https://fedorapeople.org/groups/katello/releases/yum/${repo}/katello/${dist}/\\$basearch/",
        gpgkey   => 'https://raw.githubusercontent.com/Katello/katello-packaging/master/repos/RPM-GPG-KEY-katello-2015',
        gpgcheck => '0',
        enabled  => '1',
      }

      class { '::certs':
        server_cert     => "/root/custom_cert/katello.example.com.crt",
        server_ca_cert  => "/root/custom_cert/ca.crt",
        server_key      => "/root/custom_cert/katello.example.com.key",
        server_cert_req => "/root/custom_cert/katello.example.com.csr",
      }
      EOS
    end

    it_behaves_like 'a idempotent resource'

    describe package('katello-certs-tools') do
      it { is_expected.to be_installed }
    end

    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-default-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" } 
      its(:subject) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
    end


    describe x509_certificate('/etc/pki/katello-certs-tools/certs/katello-server-ca.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'SSL server CA' }
      its(:issuer) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=CustomKatelloCA/CN=www.custom-katello-ca.example.com" }
      its(:subject) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=CustomKatelloCA/CN=www.custom-katello-ca.example.com" }
    end
  end
end
