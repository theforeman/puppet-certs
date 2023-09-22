require 'fileutils'
require File.expand_path('../../katello_ssl_tool', __FILE__)

Puppet::Type.type(:cert).provide(:katello_ssl_tool, :parent => Puppet::Provider::KatelloSslTool::Cert) do

  def generate!
    args = [ "--gen-#{resource[:purpose]}",
              '--dir', resource[:build_dir],
              '--set-hostname', resource[:hostname],
              '--server-cert', File.basename(pubkey),
              '--server-cert-req', File.basename(req_file),
              '--server-key', File.basename(privkey),
              '--no-rpm' ]

    resource[:common_name] ||= resource[:hostname]
    args.concat(['--password', "file:#{resource[:password_file]}",
                 '--set-hostname', resource[:hostname],
                 '--set-common-name', resource[:common_name],
                 '--ca-cert', ca_details[:pubkey],
                 '--ca-key', ca_details[:privkey]])
    args.concat(common_args)

    if resource[:cname]
      if resource[:cname].is_a?(String)
        args << ['--set-cname', resource[:cname]]
      else
        args << resource[:cname].map { |cname| ['--set-cname', cname] }.flatten
      end
    end

    katello_ssl_tool(*args)
    super
  end

  protected

  def req_file
    "#{pubkey}.req"
  end
end
