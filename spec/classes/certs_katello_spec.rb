require 'spec_helper'

describe 'certs::katello' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with parameters' do
        let :pre_condition do
          "class {'certs': pki_dir => '/tmp', server_ca_name => 'server_ca', default_ca_name => 'default_ca'}"
        end

        it { should contain_trusted_ca__ca('katello_server-host-cert').with_source('/tmp/certs/server_ca.crt') }

        it do
          should contain_certs_bootstrap_rpm('katello-ca-consumer-foo.example.com')
            .with_dir('/var/www/html/pub')
            .with_summary('Subscription-manager consumer certificate for Katello instance foo.example.com')
            .with_description('Consumer certificate and post installation script that configures rhsm.')
            .with_files(['/usr/bin/katello-rhsm-consumer:755=/var/www/html/pub/katello-rhsm-consumer'])
            .with_bootstrap_script('/bin/bash /usr/bin/katello-rhsm-consumer')
            .with_postun_script("if [ $1 -eq 0 ]; then\ntest -f /etc/rhsm/rhsm.conf.kat-backup && command cp /etc/rhsm/rhsm.conf.kat-backup /etc/rhsm/rhsm.conf\nfi\n")
            .with_alias('katello-ca-consumer-latest.noarch.rpm')
            .that_subscribes_to(['Ca[server_ca]', 'Certs::Rhsm_reconfigure_script[/var/www/html/pub/katello-rhsm-consumer]'])
        end
      end
    end
  end
end
