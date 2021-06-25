require 'spec_helper'

describe 'certs::keypair' do
  let(:title) { 'mykeypair' }
  let(:params) do
    {
      key_pair: 'Ca[default]',
      key_file: '/path/to/key.pem',
      cert_file: '/path/to/cert.pem',
    }
  end
  let(:pre_condition) do
    <<-PUPPET
    ca { 'default':
    }
    PUPPET
  end

  context 'with minimal parameters' do
    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_privkey('/path/to/key.pem')
        .with_key_pair('Ca[default]')
        .with_unprotect(false)
        .with_password_file(nil)
        .that_subscribes_to('Ca[default]')
    end

    it do
      is_expected.to contain_pubkey('/path/to/cert.pem')
        .with_key_pair('Ca[default]')
        .with_strip(false)
        .that_subscribes_to(['Ca[default]', 'Privkey[/path/to/key.pem]'])
    end

    it { is_expected.not_to contain_file('/path/to/key.pem') }
    it { is_expected.not_to contain_file('/path/to/cert.pem') }
  end

  context 'with manage_key => true' do
    let(:params) { super().merge(manage_key: true) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.to contain_file('/path/to/key.pem').that_requires('Privkey[/path/to/key.pem]') }
    it { is_expected.not_to contain_file('/path/to/cert.pem') }
  end

  context 'with manage_cert => true' do
    let(:params) { super().merge(manage_cert: true) }

    it { is_expected.to compile.with_all_deps }
    it { is_expected.not_to contain_file('/path/to/key.pem') }
    it { is_expected.to contain_file('/path/to/cert.pem').that_requires('Pubkey[/path/to/cert.pem]') }
  end
end
