require 'spec_helper_acceptance'

describe 'certs' do
  nssdb_dir = '/etc/pki/katello/nssdb'
  nssdb_password_file = "#{nssdb_dir}/nss_db_password-file"

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

    describe x509_certificate("/etc/pki/katello/certs/#{host_inventory['fqdn']}-qpid-broker.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      include_examples 'certificate issuer', "C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      include_examples 'certificate subject', "C = US, ST = North Carolina, O = pulp, OU = SomeOrgUnit, CN = #{host_inventory['fqdn']}"
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/etc/pki/katello/private/#{host_inventory['fqdn']}-qpid-broker.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/etc/pki/katello/certs/#{host_inventory['fqdn']}-qpid-broker.crt") }
    end

    describe file(nssdb_password_file) do
      it { should be_file }
      it { should be_mode 640 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'qpidd' }
    end

    describe file(nssdb_dir) do
      it { should be_directory }
      it { should be_mode 755 }
      it { should be_owned_by 'root' }
      it { should be_grouped_into 'qpidd' }
    end

    describe nssdb(nssdb_dir) do
      its(:certificates) { should match(/^ca                                                           CT,C,c$/i) }
      its(:certificates) { should match(/^broker                                                       u,u,u$/i) }
    end

    describe nssdb_certificate(nssdb_dir, name: 'ca') do
      its(:exit_status) { should eq 0 }
      its(:subject) { should match(/CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US/) }
      its(:issuer) { should match(/CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US/) }
    end

    describe nssdb_certificate(nssdb_dir, name: 'broker') do
      its(:exit_status) { should eq 0 }
      its(:subject) { should match(/CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=pulp,ST=North Carolina,C=US/) }
      its(:issuer) { should match(/CN=#{host_inventory['fqdn']},OU=SomeOrgUnit,O=Katello,L=Raleigh,ST=North Carolina,C=US/) }
    end

    # TODO: nssdb_private_key
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
