require 'spec_helper'

describe 'certs::ca' do
  let :facts do
    on_supported_os['redhat-7-x86_64']
  end

  context 'without params ' do
    let :pre_condition do
      "class {'certs':}"
    end

    describe 'with ca set' do
      it { should contain_ca('katello-default-ca').with({ :other_certs => [] }) }
    end
  end

  context 'with params' do
    let :pre_condition do
      "class {'certs': other_default_ca_certs => ['/tmp/other-default-cert.crt', '/tmp/another-default-cert.crt']}"
    end

    describe 'with ca set' do
      it { should contain_ca('katello-default-ca').with({ :other_certs => ['/tmp/other-default-cert.crt', '/tmp/another-default-cert.crt'] }) }
    end
  end
end
