require File.expand_path('../certs_common', __FILE__)

Puppet::Type.newtype(:ca) do
  desc 'Ca for generating signed certs'

  instance_eval(&Certs::CERT_COMMON_PARAMS)

  newparam(:other_certs, :array_matching => :all) do
    validate do |value|
      unless value.is_a?(Array) || value.is_a?(String) || value.is_a?(Symbol)
        raise Puppet::Error, "Puppet::Type::Ca: other_certs parameter must be an array or a string,
          got #{value.class.name}."
      end
    end

    munge do |value|
      return [value] if value.is_a?(String) || value.is_a?(Symbol)
      value
    end

    defaultto Array.new
  end

end
