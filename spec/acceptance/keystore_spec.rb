require 'spec_helper_acceptance'

describe 'certs' do
  context 'with keystore type' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        $keystore_password_file = '/etc/pki/keystore_password-file'

        package { 'java-11-openjdk-headless':
          ensure => installed,
        }

        file { $keystore_password_file:
          ensure    => file,
          content   => 'testpassword',
          owner     => 'root',
          group     => 'root',
          mode      => '0440',
          show_diff => false,
        }

        keystore { "/etc/pki/keystore":
          ensure        => present,
          password_file => $keystore_password_file,
          owner         => 'root',
          group         => 'root',
          mode          => '0640',
        }
        PUPPET
      end
    end

    describe file('/etc/pki/keystore') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command("keytool -list -keystore /etc/pki/keystore -storepass testpassword") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
    end

    describe 'changing password' do
      describe 'apply puppet' do
        let(:manifest) do
          <<-PUPPET
          $keystore_password_file = '/etc/pki/keystore_password-file'

          package { 'java-11-openjdk-headless':
            ensure => installed,
          }

          file { $keystore_password_file:
            ensure    => file,
            content   => 'other-password',
            owner     => 'root',
            group     => 'root',
            mode      => '0440',
            show_diff => false,
          }

          keystore { "/etc/pki/keystore":
            ensure        => present,
            password_file => $keystore_password_file,
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

      describe command("keytool -list -keystore /etc/pki/keystore -storepass other-password") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
        its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
      end
    end

    describe 'noop' do
      describe 'change password file' do
        let(:manifest) do
          <<-PUPPET
          file { '/etc/pki/keystore_password-file':
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
          $keystore_password_file = '/etc/pki/keystore_password-file'

          package { 'java-11-openjdk-headless':
            ensure => installed,
          }

          file { $keystore_password_file:
            ensure    => file,
            content   => 'other-password',
            owner     => 'root',
            group     => 'root',
            mode      => '0440',
            show_diff => false,
          }

          keystore { "/etc/pki/keystore":
            ensure        => present,
            password_file => $keystore_password_file,
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

      describe file('/etc/pki/keystore') do
        it { is_expected.to be_file }
      end

      # Should still be readable with the old password
      describe command("keytool -list -keystore /etc/pki/keystore -storepass other-password") do
        its(:exit_status) { should eq 0 }
        its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
        its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
      end
    end
  end
end
