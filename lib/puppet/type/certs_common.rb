module Certs

  CERT_COMMON_PARAMS = Proc.new do
    ensurable

    # make ensure present default
    define_method(:managed?) { true }

    newparam(:name, :namevar => true)

    newparam(:custom_pubkey)

    newparam(:custom_privkey)

    newparam(:custom_req)

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

    newparam(:deploy)

    newparam(:password_file)

    newparam(:ca) do
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
  end

  FILE_COMMON_PARAMS = Proc.new do
    ensurable

    newparam(:path, :namevar => true)

    newparam(:password_file)

    # make ensure present default
    define_method(:managed?) { true }

    newparam(:key_pair) do
      validate do |value|
        param_resource = resource.catalog.resource(value.to_s)
        if param_resource && !['Puppet::Type::Ca', 'Puppet::Type::Cert'].include?(param_resource.class.to_s)
          raise ArgumentError, "Expected Ca or Cert resource, got #{param_resource.class} #{param_resource.inspect}"
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

    autorequire(:file) do
      @parameters[:path]
    end

  end
end
