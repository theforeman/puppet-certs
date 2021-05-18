Puppet::Type.newtype(:keystore) do
  desc 'generates an empty pkcs12 keystore'

  ensurable

  newparam(:keystore, :namevar => true) do
    desc "Path to the keystore"
    isrequired
  end

  newparam(:password_file) do
    desc "Path to file containing the keystore password"
    isrequired
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Specifies the owner of the keystore. Valid options: a string containing a username or integer containing a uid."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Specifies a permissions group for the keystore. Valid options: a string containing a group name or integer containing a gid."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Specifies the permissions mode of the keystore. Valid options: a string containing a permission mode value in octal notation."
  end

  autorequire(:file) do
    [self[:password_file]]
  end

  def generate
    file_opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file,
      path: self[:keystore],
    }

    [:owner,
     :group,
     :mode].each do |param|
      file_opts[param] = self[param] unless self[param].nil?
    end

    metaparams = Puppet::Type.metaparams
    excluded_metaparams = [:before, :notify, :require, :subscribe, :tag]

    metaparams.reject! { |param| excluded_metaparams.include? param }

    metaparams.each do |metaparam|
      file_opts[metaparam] = self[metaparam] unless self[metaparam].nil?
    end

    [Puppet::Type.type(:file).new(file_opts)]
  end
end
