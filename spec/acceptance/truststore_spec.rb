require 'spec_helper_acceptance'

describe 'certs' do
  truststore_password_file = '/etc/pki/truststore_password-file'
  truststore_path = '/etc/pki/truststore'

  context 'with truststore type' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        $truststore_password_file = '/etc/pki/truststore_password-file'

        package { 'java-17-openjdk-headless':
          ensure => installed,
        }

        file { $truststore_password_file:
          ensure    => file,
          content   => 'testpassword',
          owner     => 'root',
          group     => 'root',
          mode      => '0440',
          show_diff => false,
        }

        truststore { "#{truststore_path}":
          ensure        => present,
          password_file => $truststore_password_file,
          owner         => 'root',
          group         => 'root',
          mode          => '0640',
        }
        PUPPET
      end
    end

    describe file(truststore_path) do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command("keytool -list -keystore #{truststore_path} -storepass testpassword") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
    end
  end

  context 'with a truststore_certificate' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        $truststore_password_file = '#{truststore_password_file}'

        $ca_key = '/etc/pki/ca.key'
        $ca_cert = '/etc/pki/ca.crt'

        exec { 'Create CA key':
          command => "/usr/bin/openssl genrsa -out '${ca_key}' 2048",
          creates => $ca_key,
        } ->
        exec { 'Create CA certficate':
          command => "/usr/bin/openssl req -new -x509 -key '${ca_key}' -out '${ca_cert}' -nodes -x509 -subj '/CN=${facts['networking']['fqdn']}'",
          creates => $ca_cert,
        }

        truststore_certificate { "#{truststore_path}:fake-ca":
          ensure        => present,
          password_file => $truststore_password_file,
          certificate   => $ca_cert,
        }
        PUPPET
      end
    end

    describe command("keytool -list -keystore #{truststore_path} -storepass $(cat #{truststore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 1 entry$/) }
      its(:stdout) { should match(/^fake-ca, .+, trustedCertEntry, $/) }
    end

    describe command("keytool -list -v -keystore #{truststore_path} -alias fake-ca -storepass $(cat #{truststore_password_file})") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Owner: CN=#{host_inventory['fqdn']}$/) }
      its(:stdout) { should match(/^Issuer: CN=#{host_inventory['fqdn']}$/) }
    end

    describe 'changing password' do
      describe 'apply puppet' do
        let(:manifest) do
          <<-PUPPET
          $truststore_password_file = '/etc/pki/truststore_password-file'

          package { 'java-17-openjdk-headless':
            ensure => installed,
          }

          file { $truststore_password_file:
            ensure    => file,
            content   => 'other-password',
            owner     => 'root',
            group     => 'root',
            mode      => '0440',
            show_diff => false,
          }

          truststore { "/etc/pki/truststore":
            ensure        => present,
            password_file => $truststore_password_file,
            owner         => 'root',
            group         => 'root',
            mode          => '0640',
          }
          PUPPET
        end

        it 'applies changes with no errors' do
          apply_manifest_on(default, manifest, expect_changes: true)
        end

        it 'applies a second time without changes' do
          apply_manifest_on(default, manifest, catch_changes: true)
        end
      end

      describe command("keytool -list -keystore #{truststore_path} -storepass other-password") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
        its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
      end
    end

    describe 'noop' do
      describe 'change password file' do
        let(:manifest) do
          <<-PUPPET
          file { '/etc/pki/truststore_password-file':
            ensure    => file,
            content   => 'wrong-password',
            owner     => 'root',
            group     => 'root',
            mode      => '0440',
            show_diff => false,
          }
          PUPPET
        end

        it 'applies changes with no errors' do
          apply_manifest_on(default, manifest, catch_failures: true)
        end
      end

      describe 'run in noop mode with wrong password' do
        let(:manifest) do
          <<-PUPPET
          $truststore_password_file = '/etc/pki/truststore_password-file'

          package { 'java-17-openjdk-headless':
            ensure => installed,
          }

          file { $truststore_password_file:
            ensure    => file,
            content   => 'other-password',
            owner     => 'root',
            group     => 'root',
            mode      => '0440',
            show_diff => false,
          }

          truststore { "/etc/pki/truststore":
            ensure        => present,
            password_file => $truststore_password_file,
            owner         => 'root',
            group         => 'root',
            mode          => '0640',
          }
          PUPPET
        end

        it 'applies changes with no errors' do
          apply_manifest_on(default, manifest, noop: true)
        end
      end

      describe file(truststore_path) do
        it { is_expected.to be_file }
      end

      # Should still be readable with the old password
      describe command("keytool -list -keystore #{truststore_path} -storepass other-password") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
        its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
      end
    end
  end
end
