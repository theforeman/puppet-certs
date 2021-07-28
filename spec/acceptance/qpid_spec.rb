require 'spec_helper_acceptance'

describe 'certs' do
  nssdb_dir = '/etc/pki/katello/nssdb'
  nssdb_password_file = "/etc/pki/katello/nss_db_password-file"
  fqdn = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build'
  end

  context 'with default params' do
    it_behaves_like 'an idempotent resource' do
      let(:manifest) do
        <<-PUPPET
        user { 'qpidd':
          ensure => present,
        }

        include certs::qpid
        PUPPET
      end
    end

    describe file("/etc/pki/katello/certs/#{fqdn}-qpid-broker.crt") do
      it { should_not exist }
    end

    describe file("/etc/pki/katello/private/#{fqdn}-qpid-broker.key") do
      it { should_not exist }
    end

    describe file(nssdb_password_file) do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'qpidd' }
    end

    describe file(nssdb_dir) do
      it { should be_directory }
      it { should be_mode 750 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'qpidd' }
    end

    describe command("certutil -L -d #{nssdb_dir}") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/^ca                                                           CT,C,c$/i) }
      its(:stdout) { should match(/^broker                                                       u,u,u$/i) }
    end

    describe command("certutil -L -d #{nssdb_dir} -n ca") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match_without_whitespace(/Subject: "CN=#{fqdn},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US"/) }
      its(:stdout) { should match_without_whitespace(/Issuer: "CN=#{fqdn},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US"/) }
    end

    describe command("certutil -L -d #{nssdb_dir} -n broker") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match_without_whitespace(/Subject: "CN=#{fqdn},OU=SomeOrgUnit,O=pulp,ST=North Carolina,C=US"/) }
      its(:stdout) { should match_without_whitespace(/Issuer: "CN=#{fqdn},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US"/) }
    end

    describe command("certutil -K -d #{nssdb_dir} -f #{nssdb_password_file} -n broker") do
      its(:exit_status) { should eq 0 }
      its(:stdout) { should match(/rsa/) }
    end
  end

  context 'updates certificate in nssdb if it changes' do
    let(:pp) do
      <<-PUPPET
      user { 'qpidd':
        ensure => present,
      }

      include certs::qpid
      PUPPET
    end

    it "checks that the fingerprint matches" do
      apply_manifest(pp, catch_failures: true)

      initial_fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /root/ssl-build/#{fqdn}/#{fqdn}-qpid-broker.crt"
      initial_fingerprint = initial_fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"
      expect(initial_truststore_output.output.strip).to include(initial_fingerprint)

      on default, "rm -rf /root/ssl-build/#{fqdn}"
      apply_manifest(pp, catch_failures: true)

      fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /root/ssl-build/#{fqdn}/#{fqdn}-qpid-broker.crt"
      fingerprint = fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"
      truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"

      expect(truststore_output.output.strip).to include(fingerprint)
      expect(fingerprint).not_to equal(initial_fingerprint)
      expect(truststore_output.output.strip).not_to include(initial_fingerprint)
    end
  end
end
