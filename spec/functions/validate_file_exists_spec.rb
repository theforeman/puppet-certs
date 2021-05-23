require 'spec_helper'
require 'puppetlabs_spec_helper/puppetlabs_spec/puppet_internals'

describe 'validate_file_exists' do
  it { is_expected.to run.with_params('foo_doesnt_exist').and_raise_error(ArgumentError) }
  it { is_expected.to run.with_params('/foo_doesnt_exist').and_raise_error(Puppet::Error, %r{/foo_doesnt_exist does not exist}) }
  it { is_expected.to run.with_params('/').and_return(true) }
  it { is_expected.to run.with_params('/', '/etc').and_return(true) }
end
