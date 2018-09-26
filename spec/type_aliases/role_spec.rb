require 'spec_helper'

describe 'Certs::Role' do
  roles = ['apache', 'foreman', 'foreman_proxy', 'puppet', 'qpid', 'qpid_client', 'qpid_router']
  it { is_expected.to allow_values('all-server', 'all-proxy') }
  roles.each do |role|
    it { is_expected.to allow_value([role]) }
  end
  it { is_expected.to allow_value(roles) }
  it { is_expected.not_to allow_value(nil) }
  it { is_expected.not_to allow_value('all') }
  it { is_expected.not_to allow_value([]) }
end
