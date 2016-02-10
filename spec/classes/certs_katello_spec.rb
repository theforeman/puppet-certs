require 'spec_helper'

describe 'certs::katello' do
  let :facts do
    {
      :concat_basedir             => '/tmp',
      :interfaces                 => '',
      :operatingsystem            => 'RedHat',
      :operatingsystemrelease     => '6',
      :operatingsystemmajrelease  => '6',
      :osfamily                   => 'RedHat',
      :fqdn                       => 'pulp.compony.net',
      :hostname                   => 'pulp',
    }
  end

  context 'with parameters' do
    let :pre_condition do
      "class {'certs': pki_dir => '/tmp', server_ca_name => 'foo'}"
    end

    describe 'with katello certs set' do
      # source format should be -> "${certs::pki_dir}/certs/${server_ca_name}.crt"
      it { should contain_trusted_ca__ca('katello_server-host-cert').with({ :source => "/tmp/certs/foo.crt" }) }
    end
  end
end
