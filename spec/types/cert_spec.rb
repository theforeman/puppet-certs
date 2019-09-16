require 'spec_helper'

describe 'cert' do
  let(:title) { 'test-cert' }

  it { is_expected.to be_valid_type.with_provider(:katello_ssl_tool) }
end
