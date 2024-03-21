require 'fileutils'
require File.expand_path('../../katello_ssl_tool', __FILE__)

Puppet::Type.type(:ca).provide(:katello_ssl_tool, :parent => Puppet::Provider::KatelloSslTool::Cert) do

  protected

  def generate!
    if existing_pubkey
      FileUtils.mkdir_p(build_path)
      FileUtils.cp(existing_pubkey, build_path(File.basename(pubkey)))
    else
      katello_ssl_tool('--gen-ca',
                       '--dir', resource[:build_dir],
                       '-p', "file:#{resource[:password_file]}",
                       '--force',
                       '--ca-cert-dir', resource[:build_dir],
                       '--set-common-name', resource[:common_name],
                       '--ca-cert', File.basename(pubkey),
                       '--ca-key', File.basename(privkey),
                       '--no-rpm',
                       *common_args)

    end
    super
  end

  def existing_pubkey
    if resource[:ca]
      ca_details[:pubkey]
    elsif resource[:custom_pubkey]
      resource[:custom_pubkey]
    end
  end
end
