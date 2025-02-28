require 'spec_helper_acceptance'

describe 'certs::foreman_proxy_content' do
  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  let(:expected_files_in_tar) do
    [
      'ssl-build/katello-default-ca.crt',
      'ssl-build/katello-server-ca.crt',
      'ssl-build/ca-bundle.crt',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.crt',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-client.crt',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy.crt',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-puppet-client.crt',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-apache.key',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy-client.key',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-foreman-proxy.key',
      'ssl-build/foreman-proxy.example.com/foreman-proxy.example.com-puppet-client.key',
    ]
  end

  context 'with default CA' do
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
    end

    describe tar('/root/foreman-proxy.example.com.tar.gz') do
      it { should exist }
      its(:contents) { should match_array(expected_files_in_tar) }
    end

    describe 'default and server ca certs match' do
      it { expect(file('/root/ssl-build/katello-default-ca.crt').content).to eq(file('/root/ssl-build/katello-server-ca.crt').content) }
    end
  end

  context 'with server certificates' do
    before(:context) do
      certs = {
        'fixtures/example.partial.solutions.crt' => '/server.crt',
        'fixtures/example.partial.solutions.key' => '/server.key',
        'fixtures/example.partial.solutions-chain.pem' => '/server-ca.crt',
      }
      certs.each do |source_path, dest_path|
        scp_to(hosts, source_path, dest_path)
      end

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
    end

    describe tar('/root/foreman-proxy.example.com.tar.gz') do
      it { should exist }
      its(:contents) { should match_array(expected_files_in_tar) }
    end

    describe 'default and server ca certs differ' do
      it { expect(file('/root/ssl-build/katello-default-ca.crt').content).not_to eq(file('/root/ssl-build/katello-server-ca.crt').content) }
    end
  end
end
