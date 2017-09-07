require 'spec_helper_acceptance'

describe 'certs::apache' do
  before(:all) do
    install_repo = <<-EOS
      yumrepo { 'katello':
        descr    => 'Katello latest',
        baseurl  => 'https://fedorapeople.org/groups/katello/releases/yum/latest/katello/el7/$basearch/',
        gpgcheck => false,
        enabled  => true,
      }
    EOS

    apply_manifest(install_repo)
  end

  context 'with default parameters' do
    let(:pp) do
      'include ::certs::apache'
    end

    it_behaves_like 'a idempotent resource'

    describe x509_certificate('/etc/pki/katello/certs/katello-apache.crt') do
      it { should be_certificate }
      it { should be_valid }
      it { should have_purpose 'server' }
      its(:issuer) { should eq "/C=US/ST=North Carolina/L=Raleigh/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
      its(:subject) { should eq "/C=US/ST=North Carolina/O=Katello/OU=SomeOrgUnit/CN=#{fact('fqdn')}" }
      its(:keylength) { should be >= 2048 }
    end

    describe x509_private_key('/etc/pki/katello/private/katello-apache.key') do
      it { should_not be_encrypted }
      it { should be_valid }
      it { should have_matching_certificate('/etc/pki/katello/certs/katello-apache.crt') }
    end
  end
end
