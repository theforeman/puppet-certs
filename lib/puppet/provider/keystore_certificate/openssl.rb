Puppet::Type.type(:keystore_certificate).provide(:openssl) do
  commands :openssl => 'openssl'
  commands :keytool => 'keytool'

  def create
    add_certificate
  end

  def destroy
    delete_certificate
  end

  def exists?
    keystore_content
  end

  def certificate
    keystore_fingerprint
  end

  def certificate=(value)
    delete_certificate unless keystore_content.nil?
    add_certificate
  end

  def fingerprint(file)
    return unless File.exist?(file)

    openssl('x509', '-sha256', '-noout', '-fingerprint', '-in', file).strip.split('=')[1]
  end

  private

  def add_certificate
    Tempfile.open('temp_keystore') do |temp_store|
      openssl(
        'pkcs12',
        '-export',
        '-in', resource[:certificate],
        '-inkey', resource[:private_key],
        '-out', temp_store.path,
        '-name', resource[:alias],
        '-CAfile', resource[:ca],
        '-password', "file:#{resource[:password_file]}"
      )

      keytool(
        '-importkeystore',
        '-noprompt',
        '-srckeystore', temp_store.path,
        '-srcstorepass:file', resource[:password_file],
        '-destkeystore', resource[:keystore],
        '-deststorepass:file', resource[:password_file],
        '-srcalias', resource[:alias],
        '-destalias', resource[:alias],
        '-J-Dcom.redhat.fips=false'
      )
    end
  rescue Puppet::ExecutionFailure => e
    Puppet.err("Failed to add certificate to keystore: #{e}")
    nil
  end

  def delete_certificate
    keytool(
      '-delete',
      '-noprompt',
      '-keystore', resource[:keystore],
      '-alias', resource[:alias],
      '-storepass:file', resource[:password_file],
      '-J-Dcom.redhat.fips=false'
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
      '-J-Dcom.redhat.fips=false'
    )
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("Failed to read keystore contents: #{e}")
    nil
  end

  def keystore_fingerprint
    keystore_content&.scan(/^Certificate fingerprint \(SHA-256\): (.+)$/)&.first&.first
  end

  def file_readable?(file)
    File.file?(file) && File.readable?(file)
  end
end
