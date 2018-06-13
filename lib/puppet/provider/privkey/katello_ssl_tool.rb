require File.expand_path('../../katello_ssl_tool', __FILE__)

Puppet::Type.type(:privkey).provide(:katello_ssl_tool, :parent => Puppet::Provider::KatelloSslTool::CertFile) do

  protected

  def expected_content
    if resource[:unprotect]
      tmp_file = "#{source_path}.tmp"
      begin
        openssl('rsa',
                '-in', source_path,
                '-out', tmp_file,
                '-passin', "file:#{resource[:password_file]}")
        File.read(tmp_file)
      ensure
        File.delete(tmp_file) if File.exist?(tmp_file)
      end
    else
      super
    end
  end

  def source_path
    key_pair = resource.catalog.resource(@resource[:key_pair].to_s)
    if key_pair.type.to_s == 'cert'
      cert_details[:privkey]
    elsif key_pair.type.to_s == 'ca'
      Puppet::Type::Ca::ProviderKatello_ssl_tool.privkey(key_pair.to_hash[:name])
    end
  end

  def mode
    0400
  end

end
