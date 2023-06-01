require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:private_key) do
  desc 'manage a private key'

  ensurable

  newparam(:path, :namevar => true) do
    desc "Path to the private key file"
    isrequired
  end

  newparam(:password_file) do
    desc "Path to file containing the private key file password"
  end

  newparam(:decrypt, parent: Puppet::Parameter::Boolean) do
    desc "If true, decrypts the private key before writing to disk. Requires password_file parameter to be set"
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Specifies the owner of the private key. Valid options: a string containing a username or integer containing a uid."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Specifies a permissions group for the private key. Valid options: a string containing a group name or integer containing a gid."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Specifies the permissions mode of the private key. Valid options: a string containing a permission mode value in octal notation."
  end

  newparam(:source, parent: Puppet::Type::File::ParameterSource) do
    desc "Specifies the source of the private key."
    isrequired
  end

  validate do
    self.fail _("You cannot specify to decrypt without including a password file") if self[:decrypt] && !self[:password_file]
  end

  autorequire(:file) do
    [self[:password_file], self[:path], self[:source]]
  end

  def generate
    file_opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file,
    }

    [:path,
     :owner,
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
