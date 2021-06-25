require 'spec_helper'

describe 'certs' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      context 'with default parameters' do
        it { is_expected.to compile.with_all_deps }
        it { is_expected.to contain_class('certs') }
        it { is_expected.to contain_class('certs::params') }

        # Install
        it { is_expected.to contain_class('certs::install') }
        it { is_expected.to contain_package('katello-certs-tools') }

        # Config
        it { is_expected.to contain_class('certs::config').that_requires('Class[certs::install]') }
        it { is_expected.to contain_file('/etc/pki/katello').with_mode('0755').with_owner('root').with_group('root') }
        it { is_expected.to contain_file('/etc/pki/katello/certs').with_mode('0755').with_owner('root').with_group('root') }
        it { is_expected.to contain_file('/etc/pki/katello/private').with_mode('0750').with_owner('root').with_group('root') }

        # CA verification
        it { is_expected.to contain_class('certs::ca').that_requires('Class[certs::config]') }

        it { is_expected.to contain_file('/etc/pki/katello/private/katello-default-ca.pwd') }
        it do
          is_expected.to contain_ca('katello-default-ca')
            .with_common_name('foo.example.com')
            .with_country('US')
            .with_state('North Carolina')
            .with_city('Raleigh')
            .with_org('Katello')
            .with_org_unit('SomeOrgUnit')
            .with_expiration('36500')
            .with_generate(true)
            .with_deploy(true)
            .that_requires('File[/etc/pki/katello/private/katello-default-ca.pwd]')
        end

        it do
          is_expected.to contain_privkey('/etc/pki/katello/private/katello-default-ca.key')
            .that_requires(['Ca[katello-default-ca]', 'File[/etc/pki/katello/private/katello-default-ca.pwd]'])
        end

        it do
          is_expected.to contain_file('/etc/pki/katello/private/katello-default-ca.key')
            .that_requires('Ca[katello-default-ca]')
            .that_subscribes_to('Privkey[/etc/pki/katello/private/katello-default-ca.key]')
        end

        it do
          is_expected.to contain_pubkey('/etc/pki/katello/certs/katello-default-ca-stripped.crt')
            .that_requires('Ca[katello-default-ca]')
        end

        it { is_expected.to contain_pubkey('/etc/pki/katello/certs/katello-default-ca.crt').that_subscribes_to('Ca[katello-default-ca]') }
        it do
          is_expected.to contain_file('/etc/pki/katello/certs/katello-default-ca.crt')
            .that_requires('Ca[katello-default-ca]')
            .that_subscribes_to('Pubkey[/etc/pki/katello/certs/katello-default-ca.crt]')
        end

        it do
          is_expected.to contain_ca('katello-server-ca')
            .with_ca('Ca[katello-default-ca]')
            .that_requires('Ca[katello-default-ca]')
        end
        it { is_expected.to contain_file('/root/ssl-build/KATELLO-TRUSTED-SSL-CERT').that_requires('Ca[katello-server-ca]') }
        it { is_expected.to contain_pubkey('/etc/pki/katello/certs/katello-server-ca.crt') }
        it do
          is_expected.to contain_file('/etc/pki/katello/certs/katello-server-ca.crt')
            .that_subscribes_to(['Ca[katello-server-ca]', 'Pubkey[/etc/pki/katello/certs/katello-server-ca.crt]'])
        end
      end
    end
  end
end
