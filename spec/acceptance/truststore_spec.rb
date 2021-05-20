require 'spec_helper_acceptance'

describe 'certs' do
  context 'with truststore type' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        $truststore_password_file = '/etc/pki/truststore_password-file'

        package { 'java-11-openjdk-headless':
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

        truststore { "/etc/pki/truststore":
          ensure        => present,
          password_file => $truststore_password_file,
          owner         => 'root',
          group         => 'root',
          mode          => '0640',
        }
        PUPPET
      end
    end

    describe file('/etc/pki/truststore') do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'root' }
    end

    describe command("keytool -list -keystore /etc/pki/truststore -storepass:file /etc/pki/truststore_password-file") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^Keystore type: PKCS12$/i) }
      its(:stdout) { should match(/^Your keystore contains 0 entries$/) }
    end
  end
end
