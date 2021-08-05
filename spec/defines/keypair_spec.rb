require 'spec_helper'

describe 'certs::keypair' do
  let(:title) { 'mykeypair' }
  let(:params) do
    {
      source_dir: '/root/ssl-build/example.com',
      key_file: '/path/to/key.pem',
      cert_file: '/path/to/cert.pem',
      key_group: 'root',
      cert_group: 'root',
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
      is_expected.to contain_file('/path/to/key.pem')
        .with_ensure('present')
        .with_source('/root/ssl-build/example.com/mykeypair.key')
        .with_owner('root')
        .with_group('root')
        .with_mode('440')
        .with_show_diff(false)
    end

    it do
      is_expected.to contain_file('/path/to/cert.pem')
        .with_ensure('present')
        .with_source('/root/ssl-build/example.com/mykeypair.crt')
        .with_owner('root')
        .with_group('root')
        .with_mode('440')
    end
  end

  context 'with key_ensure => absent and cert_ensure => absent' do
    let(:params) { super().merge(key_ensure: 'absent', cert_ensure: 'absent') }

    it { is_expected.to compile.with_all_deps }
    it do
      is_expected.to contain_file('/path/to/key.pem')
        .with_ensure('absent')
        .with_source('/root/ssl-build/example.com/mykeypair.key')
        .with_owner('root')
        .with_group('root')
        .with_mode('440')
        .with_show_diff(false)
    end

    it do
      is_expected.to contain_file('/path/to/cert.pem')
        .with_ensure('absent')
        .with_source('/root/ssl-build/example.com/mykeypair.crt')
        .with_owner('root')
        .with_group('root')
        .with_mode('440')
    end
  end
end
