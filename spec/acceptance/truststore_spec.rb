require 'spec_helper_acceptance'

describe 'certs' do
  truststore_password_file = '/etc/pki/truststore_password-file'
  truststore_path = '/etc/pki/truststore'

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

    describe command("keytool -list -keystore #{truststore_path} -storepass:file #{truststore_password_file}") do
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
  end
end
