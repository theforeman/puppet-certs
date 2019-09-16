require 'spec_helper'

describe 'ca' do
  let(:title) { 'test-ca' }

  it { is_expected.to be_valid_type.with_provider(:katello_ssl_tool) }
end
