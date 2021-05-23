require 'spec_helper'

describe 'key_bundle' do
  let(:title) { 'test-bundle' }

  it { is_expected.to be_valid_type.with_provider(:katello_ssl_tool) }

  describe 'autorequiring' do
    let(:catalog) { Puppet::Resource::Catalog.new }

    it 'autorequires files' do
      parent = Puppet::Type.type(:file).new(name: '/etc/pki/katello/bundles')
      catalog.add_resource parent

      resource = Puppet::Type.type(:key_bundle).new(name: title, path: '/etc/pki/katello/bundles/test-bundle.pem')
      catalog.add_resource resource

      req = resource.autorequire
      expect(req.size).to eq(1)
      expect(req[0].target).to eq(resource)
      expect(req[0].source).to eq(parent)
    end
  end
end
