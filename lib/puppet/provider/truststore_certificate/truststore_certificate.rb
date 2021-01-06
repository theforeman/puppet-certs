Puppet::Type.type(:truststore_certificate).provide(:truststore_certificate) do

  commands :keytool => 'keytool'
  commands :openssl => 'openssl'

  def create
    add_certificate unless certificate_present?
    if certificate_changed?
      delete_certificate
      add_certificate
    end
  end

  def destroy
    delete_certificate if truststore_exists? && certificate_present?
  end

  def exists?
    truststore_exists? && !certificate_changed?
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
      resource[:name],
      '-file',
      resource[:certificate],
      '-storepass:file',
      resource[:password_file]
    )
  end

  def delete_certificate
    delete = keytool(
      '-delete',
      '-v',
      '-noprompt',
      '-keystore',
      resource[:truststore],
      '-alias',
      resource[:name],
      '-storepass:file',
      resource[:password_file]
    )
  end

  def truststore_contents
    keytool(
      '-list',
      '-keystore',
      resource[:truststore],
      '-storepass:file',
      resource[:password_file]
    )
  end

  def truststore_exists?
    File.exist?(resource[:truststore])
  end

  def certificate_present?
    truststore_exists? && truststore_contents.include?(resource[:name])
  end

  def certificate_changed?
    return true unless certificate_present?

    fingerprint = openssl('x509', '-noout', '-fingerprint', '-in', resource[:certificate]).strip.split('=')[1]
    !truststore_contents.include?(fingerprint)
  end

end
