module PuppetX
  module Certs
    module Common

      CERT_COMMON_PARAMS = Proc.new do
        ensurable

        # make ensure present default
        define_method(:managed?) { true }

        newparam(:name, :namevar => true)

        newparam(:common_name)

        newparam(:cname)

        newparam(:email)

        newparam(:country)

        newparam(:state)

        newparam(:city)

        newparam(:org)

        newparam(:org_unit)

        newparam(:expiration)

        newparam(:generate)

        newparam(:regenerate)

        newparam(:password_file)

        newparam(:build_dir) do
          defaultto('/root/ssl-build')

          validate do |value|
            if value.empty?
              raise ArgumentError, "build_dir cannot be empty"
            else
              super(value)
            end
          end
        end

        newparam(:ca) do
          isrequired

          validate do |value|
            ca_resource = resource.catalog.resource(value.to_s)
            if ca_resource
              # rspec-puppet presents Puppet::Resource instances
              resource_type = ca_resource.is_a?(Puppet::Resource) ? ca_resource.resource_type.to_s : ca_resource.class.to_s
              if resource_type != 'Puppet::Type::Ca'
                raise ArgumentError, "Expected Ca resource, got #{ca_resource.class} #{ca_resource.inspect}"
              end
            else
              raise ArgumentError, "Ca #{value} not found in catalog"
            end
          end
        end

        autorequire(:ca) do
          if @parameters.has_key?(:ca)
            catalog.resource(@parameters[:ca].value.to_s).to_hash[:name]
          end
        end

        autorequire(:file) do
          [self[:password_file]].compact
        end
      end

      FILE_COMMON_PARAMS = Proc.new do
        ensurable

        newparam(:path, :namevar => true) do
          isrequired
        end

        newparam(:password_file)

        # ensure RSA string is present in -----(BEGIN/END) (RSA )?PRIVATE KEY-----
        newparam(:force_rsa)

        # make ensure present default
        define_method(:managed?) { true }

        newparam(:key_pair) do
          isrequired

          validate do |value|
            param_resource = resource.catalog.resource(value.to_s)

            if param_resource
              # rspec-puppet presents Puppet::Resource instances
              resource_type = param_resource.is_a?(Puppet::Resource) ? param_resource.resource_type : param_resource.class
              unless ['Puppet::Type::Ca', 'Puppet::Type::Cert'].include?(resource_type.to_s)
                raise ArgumentError, "Expected Ca or Cert resource, got #{resource_type} #{param_resource.inspect}"
              end
            else
              raise ArgumentError, "Key_pair #{value} not found in catalog"
            end
          end
        end

        define_method(:autorequire_cert) do |type|
          if @parameters.has_key?(:key_pair)
            key_pair = catalog.resource(@parameters[:key_pair].value.to_s)
            key_pair.to_hash[:name] if key_pair && key_pair.type == type
          end
        end

        autorequire(:cert) do
          autorequire_cert('Cert')
        end

        autorequire(:ca) do
          autorequire_cert('Ca')
        end

        # Autorequire the nearest ancestor directory found in the catalog.
        # Copied from Puppet's lib/puppet/type/file.rb
        autorequire(:file) do
          req = []
          req << self[:password_file] if self[:password_file]
          path = Pathname.new(self[:path])
          if !path.root?
            # Start at our parent, to avoid autorequiring ourself
            parents = path.parent.enum_for(:ascend)
            found = parents.find { |p| catalog.resource(:file, p.to_s) }
            if found
              req << found.to_s
            end
          end
          req
        end
      end
    end
  end
end
