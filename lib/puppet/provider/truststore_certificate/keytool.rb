Puppet::Type.type(:truststore_certificate).provide(:keytool) do
  commands :keytool => 'keytool'
  commands :openssl => 'openssl'

  def create
    add_certificate
  end

  def destroy
    delete_certificate
  end

  def exists?
    truststore_content
  end

  def certificate
    truststore_fingerprint
  end

  def certificate=(value)
    delete_certificate unless truststore_content.nil?
    add_certificate
  end

  def fingerprint(file)
    return unless File.exist?(file)

    openssl('x509', '-noout', '-fingerprint', '-in', file).strip.split('=')[1]
  end

  def file_readable?(file)
    File.file?(file) && File.readable?(file)
  end

  private

  def add_certificate
    keytool(
      '-import',
      '-v',
      '-noprompt',
      '-storetype',
      'pkcs12',
      '-keystore',
      resource[:truststore],
      '-alias',
      resource[:alias],
      '-file',
      resource[:certificate],
      '-storepass:file',
      resource[:password_file]
    )
  end

  def delete_certificate
    keytool(
      '-delete',
      '-v',
      '-noprompt',
      '-keystore',
      resource[:truststore],
      '-alias',
      resource[:alias],
      '-storepass:file',
      resource[:password_file]
    )
  end

  def truststore_content
    return unless file_readable?(resource[:truststore])
    return unless file_readable?(resource[:password_file])

    keytool(
      '-list',
      '-keystore', resource[:truststore],
      '-storepass:file', resource[:password_file],
      '-alias', resource[:alias],
    )
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("Failed to read truststore contents: #{e}")
    # TODO: distinguish between invalid password, alias doesn't exist and others?
    nil
  end

  def truststore_fingerprint
    # TODO: include fingerprint type in the output?
    truststore_content&.scan(/^Certificate fingerprint \(SHA1\): (.+)$/)&.first&.first
  end
end
