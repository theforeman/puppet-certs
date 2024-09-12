require 'fileutils'
module Puppet::Provider::KatelloSslTool

  class Cert < Puppet::Provider

    initvars

    commands :katello_ssl_tool_command => 'katello-ssl-tool'

    def exists?
      !generate?
    end

    def create
      generate! if generate?
    end

    def destroy
    end

    def details(cert_name)
      return {
        :pubkey  => pubkey(cert_name),
        :privkey => privkey(cert_name)
      }
    end

    protected

    def katello_ssl_tool(*args)
      Dir.chdir('/root') do
        katello_ssl_tool_command(*args)
      end
    end

    def generate!
      FileUtils.rm_f(update_file)
    end

    def generate?
      return false unless resource[:generate]
      return true if resource[:regenerate]
      return true if File.exists?(update_file)
      return true unless (File.exist?(pubkey) && File.exist?(privkey))
    end

    def update_file
      build_path("#{resource[:name]}.update")
    end

    def common_args
      [ '--set-country', resource[:country],
       '--set-state', resource[:state],
       '--set-city', resource[:city],
       '--set-org', resource[:org],
       '--set-org-unit', resource[:org_unit],
       '--set-email', resource[:email],
       '--cert-expiration', resource[:expiration]]
    end

    def pubkey(cert_name = resource[:name])
      build_path("#{cert_name}.crt")
    end

    def privkey(key_name = resource[:name])
      build_path("#{key_name}.key")
    end

    def build_path(file_name = '')
      path = resource[:build_dir]

      if resource.to_hash.key?(:hostname)
        path = "#{path}/#{resource[:hostname]}"
      end

      File.join(path, file_name)
    end

    def ca_details
      return @ca_details if defined? @ca_details
      if ca_resource = resource.catalog.resource(@resource[:ca].to_s)
        name = ca_resource.to_hash[:name]
        @ca_details = details(name)
      else
        raise 'Wanted to generate cert without ca specified'
      end
    end
  end
end
