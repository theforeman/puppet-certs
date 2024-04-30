require 'spec_helper_acceptance'

describe 'certs::foreman_proxy_content' do
  fqdn = fact('fqdn')

  before(:all) do
    on default, 'rm -rf /root/ssl-build /etc/pki/katello'
  end

  context 'with foreman true' do
    before(:context) do
      manifest = <<~PUPPET
        class { 'certs::generate':
          foreman => true,
        }
      PUPPET

      apply_manifest(manifest, catch_failures: true)
    end

    describe x509_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-client.crt") do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'client' }
      its(:issuer) { should match_without_whitespace(/C = US, ST = North Carolina, L = Raleigh, O = Katello, OU = SomeOrgUnit, CN = #{fqdn}/) }
      its(:subject) { should match_without_whitespace(/C = US, ST = North Carolina, O = FOREMAN, OU = PUPPET, CN = #{fqdn}/) }
      its(:keylength) { should be >= 4096 }
    end

    describe x509_private_key("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-client.key") do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate("/root/ssl-build/#{fqdn}/#{fqdn}-foreman-client.crt") }
    end
  end
end
