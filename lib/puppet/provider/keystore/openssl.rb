Puppet::Type.type(:keystore).provide(:openssl) do
  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  def create
    create_keystore
  end

  def destroy
    File.delete(resource[:keystore])
  end

  def exists?
    keystore_content
  end

  def certificate
    keystore_fingerprint
  end

  def certificate=(value)
    destroy unless keystore_content.nil?
    create_keystore
  end

  def fingerprint(file)
    return unless File.exist?(file)

    openssl('x509', '-sha256', '-noout', '-fingerprint', '-in', file).strip.split('=')[1]
  end

  private

  def create_keystore
    openssl(
      'pkcs12',
      '-export',
      '-in', resource[:certificate],
      '-inkey', resource[:private_key],
      '-out', resource[:keystore],
      '-name', resource[:alias],
      '-CAfile', resource[:ca_file],
      '-password', "file:#{resource[:password_file]}"
    )
  end

  def keystore_content
    return unless file_readable?(resource[:keystore])
    return unless file_readable?(resource[:password_file])

    keytool(
      '-list',
      '-keystore', resource[:keystore],
      '-storepass:file', resource[:password_file],
      '-alias', resource[:alias],
    )
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("Failed to read keystore contents: #{e}")
    # TODO: distinguish between invalid password, alias doesn't exist and others?
    nil
  end

  def keystore_fingerprint
    # TODO: include fingerprint type in the output?
    keystore_content&.scan(/^Certificate fingerprint \(SHA-256\): (.+)$/)&.first&.first
  end

  def file_readable?(file)
    File.file?(file) && File.readable?(file)
  end
end
