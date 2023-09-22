require 'fileutils'
require File.expand_path('../../katello_ssl_tool', __FILE__)

Puppet::Type.type(:ca).provide(:katello_ssl_tool, :parent => Puppet::Provider::KatelloSslTool::Cert) do

  protected

  def generate!
    katello_ssl_tool(
      '--gen-ca',
      '--dir', resource[:build_dir],
      '--password', "file:#{resource[:password_file]}",
      '--force',
      '--ca-cert-dir', resource[:build_dir],
      '--set-common-name', resource[:common_name],
      '--ca-cert', File.basename(pubkey),
      '--ca-key', File.basename(privkey),
      '--no-rpm',
      *common_args
    )

    super
  end
end
