require 'spec_helper'

describe 'certs::generate_archive' do
  on_os_under_test.each do |os, facts|
    context "on #{os}" do
      let(:facts) { facts }
      let(:params) do
        {
          hostname: 'machine.example.com',
          certs_tar: 'machine.example.com',
        }
      end

      ['all-server', 'all-proxy'].each do |role|
        context "with #{role}" do
          let(:params) { super().merge(role: role) }
          it { is_expected.to compile.with_all_deps }
        end
      end
    end
  end
end
