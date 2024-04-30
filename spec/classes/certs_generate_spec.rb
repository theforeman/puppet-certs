require 'spec_helper'

describe 'certs::generate' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      describe 'with default parameters' do
        it { should compile.with_all_deps }
      end

      describe 'with apache true' do
        let :params do
          { apache: true }
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_class('certs::apache')
        end
      end

      describe 'with foreman true' do
        let :params do
          { foreman: true }
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_class('certs::foreman')
        end
      end

      describe 'with candlepin true' do
        let :params do
          { candlepin: true }
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_class('certs::candlepin')
        end
      end

      describe 'with foreman_proxy true' do
        let :params do
          { foreman_proxy: true }
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_class('certs::foreman_proxy')
        end
      end

      describe 'with puppet true' do
        let :params do
          { puppet: true }
        end

        it { should compile.with_all_deps }

        it do
          is_expected.to contain_class('certs::puppet')
        end
      end
    end
  end
end
