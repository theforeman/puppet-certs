require 'puppet/type/file/owner'
require 'puppet/type/file/group'
require 'puppet/type/file/mode'

Puppet::Type.newtype(:nssdb) do
  desc "Generates an empty NSS database"

  ensurable

  newparam(:nssdb_dir, :namevar => true) do
    desc "Path to NSS database directory"
    isrequired
  end

  newparam(:password_file) do
    desc "Path to file containing the NSS database password"
    isrequired
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Specifies the owner of the NSS database directory and files. Valid options: a string containing a username or integer containing a uid."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Specifies a permissions group for the NSS database directory and files. Valid options: a string containing a group name or integer containing a gid."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Specifies the permissions mode of the NSS database files. Valid options: a string containing a permission mode value in octal notation."
  end

  autorequire(:file) do
    [self[:password_file]]
  end

  def generate
    file_opts = {
      :path    => self[:nssdb_dir],
      :ensure  => self[:ensure] == :absent ? :absent : :directory,
      :recurse => true
    }

    [:owner, :group, :mode].each do |param|
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
