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
            if ca_resource && ca_resource.class.to_s != 'Puppet::Type::Ca'
              raise ArgumentError, "Expected Ca resource, got #{ca_resource.class} #{ca_resource.inspect}"
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
    end
  end
end
