require 'spec_helper_acceptance'

describe 'certs' do
  nssdb_dir = '/etc/pki/katello/nssdb'
  nssdb_password_file = "#{nssdb_dir}/nss_db_password-file"

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

    describe x509_certificate("/etc/pki/katello/certs/#{host_inventory['fqdn']}-qpid-broker.crt") do
      it { is_expected.to be_certificate }
      it { is_expected.to be_valid }
      it { is_expected.to have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = pulp, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      its(:keylength) { is_expected.to be >= 2048 }
    end

    describe x509_private_key("/etc/pki/katello/private/#{host_inventory['fqdn']}-qpid-broker.key") do
      it { is_expected.not_to be_encrypted }
      it { is_expected.to be_valid }
      it { is_expected.to have_matching_certificate("/etc/pki/katello/certs/#{host_inventory['fqdn']}-qpid-broker.crt") }
    end

    describe file(nssdb_password_file) do
      it { is_expected.to be_file }
      it { is_expected.to be_mode 640 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'qpidd' }
    end

    describe file(nssdb_dir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_mode 755 }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'qpidd' }
    end

    describe command("certutil -L -d #{nssdb_dir}") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{^ca                                                           CT,C,c$}i) }
      its(:stdout) { is_expected.to match(%r{^broker                                                       u,u,u$}i) }
    end

    describe command("certutil -L -d #{nssdb_dir} -n ca") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{\s*Subject: "CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleig\n\s*h,ST=North Carolina,C=US"}) }
      its(:stdout) { is_expected.to match(%r{\s*Issuer: "CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleigh\n\s*,ST=North Carolina,C=US"}) }
    end

    describe command("certutil -L -d #{nssdb_dir} -n broker") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{\s*Subject: "CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=pulp,ST=North Ca\n\s*rolina,C=US"}) }
      its(:stdout) { is_expected.to match(%r{\s*Issuer: "CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleigh\n\s*,ST=North Carolina,C=US"}) }
    end

    describe command("certutil -K -d #{nssdb_dir} -f #{nssdb_password_file} -n broker") do
      its(:exit_status) { is_expected.to eq 0 }
      its(:stdout) { is_expected.to match(%r{rsa}) }
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

    it 'checks that the fingerprint matches' do
      apply_manifest(pp, catch_failures: true)

      initial_fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /etc/pki/katello/certs/#{host_inventory['fqdn']}-qpid-broker.crt"
      initial_fingerprint = initial_fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"
      expect(initial_truststore_output.output.strip).to include(initial_fingerprint)

      on default, "rm -rf /root/ssl-build/#{host_inventory['fqdn']}"
      apply_manifest(pp, catch_failures: true)

      fingerprint_output = on default, "openssl x509 -noout -fingerprint -sha256 -in /root/ssl-build/#{host_inventory['fqdn']}/#{host_inventory['fqdn']}-qpid-broker.crt"
      fingerprint = fingerprint_output.output.strip.split('=').last
      initial_truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"
      truststore_output = on default, "certutil -L -d #{nssdb_dir} -n broker"

      expect(truststore_output.output.strip).to include(fingerprint)
      expect(fingerprint).not_to equal(initial_fingerprint)
      expect(truststore_output.output.strip).not_to include(initial_fingerprint)
    end
  end
end
