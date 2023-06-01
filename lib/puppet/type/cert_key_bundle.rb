require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:cert_key_bundle) do
  desc 'combines a certificate and private key into a single file'

  ensurable

  newparam(:path, :namevar => true) do
    desc "Path to the file that will contain the certificate and private key bundle"
    isrequired
  end

  newparam(:certificate) do
    desc "Path to certificate file to include in bundle"
    isrequired
  end

  newparam(:private_key) do
    desc "Path to private key file to include in bundle"
    isrequired
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Specifies the owner of the file. Valid options: a string containing a username or integer containing a uid."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Specifies a permissions group for the file. Valid options: a string containing a group name or integer containing a gid."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Specifies the permissions mode of the file. Valid options: a string containing a permission mode value in octal notation."
  end

  newparam(:force_pkcs_1, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Ensures the private key is in PKCS#1 format. This is required for services like Apache reverse proxy"
  end

  def create
    File.write(self[:path], bundle)
  end

  def exists?
    return false unless File.file?(self[:path])
    return false unless File.readable?(self[:path])
    bundle == File.read(self[:path])
  end

  def destroy
    File.rm(self[:path])
  end

  def bundle
    cert = File.read(self[:certificate])
    key = File.read(self[:private_key])

    key = format_as_pkcs_1(key) if self[:force_pkcs_1]

    [key, cert].join("\n")
  end

  def format_as_pkcs_1(content)
    OpenSSL::PKey::RSA.new(content).to_pem
  end

  def generate
    file_opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file,
      show_diff: false,
    }

    [:owner,
     :path,
     :group,
     :mode].each do |param|
      file_opts[param] = self[param] unless self[param].nil?
    end

    excluded_metaparams = [:before, :notify, :require, :subscribe, :tag]

    Puppet::Type.metaparams.each do |metaparam|
      unless self[metaparam].nil? || excluded_metaparams.include?(metaparam)
        file_opts[metaparam] = self[metaparam]
      end
    end

    [Puppet::Type.type(:file).new(file_opts)]
  end

end
