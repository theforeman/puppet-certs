Puppet::Type.type(:certificate_file).provide(:openssl) do
  commands :openssl => 'openssl'
end
