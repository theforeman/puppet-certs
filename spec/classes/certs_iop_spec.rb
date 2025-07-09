require 'spec_helper'

describe 'certs::iop' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let :facts do
        os_facts
      end

      let(:pre_condition) { 'include certs' }

      describe 'with default parameters' do
        it { should compile.with_all_deps }

        it 'should create server certificate' do
          should contain_cert('localhost-iop-core-gateway-server').with(
            :ensure        => 'present',
            :hostname      => 'localhost',
            :purpose       => nil,
            :country       => 'US',
            :state         => 'North Carolina',
            :city          => 'Raleigh',
            :org           => 'Katello',
            :org_unit      => 'SomeOrgUnit',
            :expiration    => '7300',
            :generate      => true,
            :regenerate    => false,
            :password_file => '/root/ssl-build/katello-default-ca.pwd',
            :build_dir     => '/root/ssl-build'
          )
        end

        it 'should create client certificate' do
          should contain_cert('localhost-iop-core-gateway-client').with(
            :ensure        => 'present',
            :hostname      => 'localhost',
            :purpose       => 'client',
            :country       => 'US',
            :state         => 'North Carolina',
            :city          => 'Raleigh',
            :org           => 'Katello',
            :org_unit      => 'SomeOrgUnit',
            :expiration    => '7300',
            :generate      => true,
            :regenerate    => false,
            :password_file => '/root/ssl-build/katello-default-ca.pwd',
            :build_dir     => '/root/ssl-build'
          )
        end
      end

      describe 'with custom hostname' do
        let(:params) { { :hostname => 'example.com' } }

        it { should compile.with_all_deps }

        it 'should create server certificate with custom hostname' do
          should contain_cert('example.com-iop-core-gateway-server').with(
            :hostname => 'example.com'
          )
        end

        it 'should create client certificate with custom hostname' do
          should contain_cert('example.com-iop-core-gateway-client').with(
            :hostname => 'example.com'
          )
        end
      end

      describe 'with generate false' do
        let(:params) { { :generate => false } }

        it { should compile.with_all_deps }

        it 'should create certificates with generate false' do
          should contain_cert('localhost-iop-core-gateway-server').with(
            :generate => false
          )
          should contain_cert('localhost-iop-core-gateway-client').with(
            :generate => false
          )
        end
      end

      describe 'with regenerate true' do
        let(:params) { { :regenerate => true } }

        it { should compile.with_all_deps }

        it 'should create certificates with regenerate true' do
          should contain_cert('localhost-iop-core-gateway-server').with(
            :regenerate => true
          )
          should contain_cert('localhost-iop-core-gateway-client').with(
            :regenerate => true
          )
        end
      end

      describe 'with custom certificate attributes' do
        let(:params) do
          {
            :country    => 'CA',
            :state      => 'Ontario',
            :city       => 'Toronto',
            :org        => 'TestOrg',
            :org_unit   => 'TestUnit',
            :expiration => '3650'
          }
        end

        it { should compile.with_all_deps }

        it 'should create certificates with custom attributes' do
          should contain_cert('localhost-iop-core-gateway-server').with(
            :country    => 'CA',
            :state      => 'Ontario',
            :city       => 'Toronto',
            :org        => 'TestOrg',
            :org_unit   => 'TestUnit',
            :expiration => '3650'
          )
          should contain_cert('localhost-iop-core-gateway-client').with(
            :country    => 'CA',
            :state      => 'Ontario',
            :city       => 'Toronto',
            :org        => 'TestOrg',
            :org_unit   => 'TestUnit',
            :expiration => '3650'
          )
        end
      end
    end
  end
end
