require 'spec_helper_acceptance'

describe 'certs::foreman_proxy_content' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default parameters' do
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
    end

    let(:expected_files_in_tar) do
      [
        'ssl-build/katello-default-ca-1.0-1.noarch.rpm',
        'ssl-build/katello-server-ca-1.0-1.noarch.rpm',
        'ssl-build/katello-default-ca.crt',
        'ssl-build/katello-server-ca.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-client-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-client-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-puppet-client-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-broker-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-client-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-server-1.0-1.noarch.rpm',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-client.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-client.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-puppet-client.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-broker.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-client.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-server.crt',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-client.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-client.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-puppet-client.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-broker.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-client.key',
        'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-qpid-router-server.key',
      ]
    end

    describe tar('/root/foreman-proxy.example.com.tar.gz') do
      it { should exist }
      its(:contents) { should match_array(expected_files_in_tar) }
    end
  end
end
