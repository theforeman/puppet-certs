Puppet::Type.newtype(:certificate_file) do
  desc 'Manages an x509 certificate file from a source certificate'

  ensurable

  newparam(:path, :namevar => true) do
    desc "Path the certificate will be copied to."
  end

  newparam(:owner, parent: Puppet::Type::File::Owner) do
    desc "Specifies the owner of the truststore. Valid options: a string containing a username or integer containing a uid."
  end

  newparam(:group, parent: Puppet::Type::File::Group) do
    desc "Specifies a permissions group for the truststore. Valid options: a string containing a group name or integer containing a gid."
  end

  newparam(:mode, parent: Puppet::Type::File::Mode) do
    desc "Specifies the permissions mode of the truststore. Valid options: a string containing a permission mode value in octal notation."
  end

  newparam(:source, parent: Puppet::Type::File::ParameterSource) do
    desc "Specifies the source certificate that will be copied to the declared location."
  end

  def generate
    file_opts = {
      ensure: (self[:ensure] == :absent) ? :absent : :file,
    }

    [:owner,
     :group,
     :source,
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
