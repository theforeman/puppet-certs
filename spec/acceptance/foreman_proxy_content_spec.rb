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

    describe file('/root/foreman-proxy.example.com.tar.gz') do
      it { should exist }
    end
  end
end
