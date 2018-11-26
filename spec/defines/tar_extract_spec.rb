require 'spec_helper'

describe 'certs::tar_extract' do
  let(:title) { '/path/to/certs.tar' }

  context 'without parameters' do
    it do
      allow(File).to receive(:exist?).and_call_original
      expect(File).to receive(:exist?).with('/path/to/certs.tar').and_return(true)
      is_expected.to compile.with_all_deps
      is_expected.to contain_exec('extract /path/to/certs.tar')
        .with_cwd('/root')
        .with_path(['/usr/bin', '/bin'])
        .with_command('tar -xaf /path/to/certs.tar')
    end
  end

  context 'with an explicit path' do
    let(:params) { { path: '/some/other/path/with/certs.tar' } }

    it do
      allow(File).to receive(:exist?).and_call_original
      expect(File).not_to receive(:exist?).with('/path/to/certs.tar')
      expect(File).to receive(:exist?).with('/some/other/path/with/certs.tar').and_return(true)
      is_expected.to compile.with_all_deps
      is_expected.to contain_exec('extract /some/other/path/with/certs.tar')
        .with_cwd('/root')
        .with_path(['/usr/bin', '/bin'])
        .with_command('tar -xaf /some/other/path/with/certs.tar')
    end
  end
end
