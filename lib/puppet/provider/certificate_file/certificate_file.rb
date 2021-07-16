Puppet::Type.type(:certificate_file).provide(:openssl) do
  commands :openssl => 'openssl'

  def source_cert
    if valid?(resource[:source_cert])
      resource[:source_cert]
    else
      raise ArgumentError, "Source certificate is not a valid x509 certificate"
    end
  end

  def valid?(certificate)
    File.exist?(certificate)
    pem_format?(certificate)
  end

  def pem_format?(certificate)
    openssl(
      'x509',
      '-inform', 'PEM',
      '-in', certificate
    )
  end
end
