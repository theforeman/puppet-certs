require 'spec_helper_acceptance'

describe 'certs' do
  before(:context) do
    setup_candlepin = <<-EOS
      yumrepo { 'katello':
        descr    => 'Katello latest',
        baseurl  => 'https://fedorapeople.org/groups/katello/releases/yum/latest/katello/el7/$basearch/',
        gpgcheck => false,
        enabled  => true,
      }

      user { 'tomcat':
        ensure => present,
      }

      group { 'qpidd':
        ensure => present,
      }

      ['/usr/share/tomcat/conf', '/etc/candlepin/certs/amqp'].each |$dir| {
        exec { "mkdir -p ${dir}":
          creates => $dir,
          path    => ['/bin', '/usr/bin'],
        }
      }

      package { 'java-1.8.0-openjdk-headless':
        ensure => installed,
      }

      include ::certs::candlepin
    EOS

    apply_manifest(setup_candlepin)
  end

  context 'katello-certs-generate for foreman-proxy' do
    certs_tar = '/proxy.example.com-certs.tar.gz'
    foreman_proxy_fqdn = 'proxy.example.com'

    pp1 = <<-EOS
      class { '::certs':
        generate => true,
        deploy   => false,
        group    => 'foreman',
        org      => 'Default_Organization',
      }
      class { '::certs::generate_archive':
        server_fqdn   => '#{foreman_proxy_fqdn}',
        certs_tar     => '#{certs_tar}',
        foreman_proxy => true,
      }
      Class['::certs'] -> Class['::certs::generate_archive']
    EOS

    it 'applies with no errors' do
      apply_manifest(pp1, catch_failures: true)
    end

    describe file(certs_tar) do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command("tar -tvf #{certs_tar}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/ssl-build\/katello-default-ca-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/katello-server-ca-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-apache-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-foreman-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-foreman-proxy-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-foreman-proxy-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-puppet-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-qpid-broker-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-qpid-client-cert-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-qpid-router-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_proxy_fqdn}\/#{foreman_proxy_fqdn}-qpid-router-server-1.0-1.noarch.rpm$/) }
    end
  end

  context 'katello-certs-generate for foreman-application' do
    certs_tar = '/foreman.example.com-certs.tar'
    foreman_fqdn = 'foreman.example.com'

    pp2 = <<-EOS
      class { '::certs':
        generate => true,
        deploy   => false,
        group    => 'foreman',
        org      => 'Default_Organization',
      }
      class { '::certs::generate_archive':
        server_fqdn         => '#{foreman_fqdn}',
        certs_tar           => '#{certs_tar}',
        foreman_application => true,
        foreman_proxy       => false,
      }
      Class['::certs'] -> Class['::certs::generate_archive']
    EOS

    it 'applies with no errors' do
      apply_manifest(pp2, catch_failures: true)
    end

    describe file(certs_tar) do
      it { should be_file }
      it { should be_mode 644 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command("tar -tvf #{certs_tar}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/ssl-build\/katello-default-ca-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/katello-server-ca-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_fqdn}\/#{foreman_fqdn}-apache-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_fqdn}\/#{foreman_fqdn}-foreman-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_fqdn}\/#{foreman_fqdn}-puppet-client-1.0-1.noarch.rpm$/) }
      its(:stdout) { should match(/ssl-build\/#{foreman_fqdn}\/#{foreman_fqdn}-qpid-client-cert-1.0-1.noarch.rpm$/) }
      its(:stdout) { should_not match(/foreman-proxy-1.0-1.noarch.rpm$/) }
    end
  end

end
