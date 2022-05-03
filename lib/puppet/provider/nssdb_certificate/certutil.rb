Puppet::Type.type(:nssdb_certificate).provide(:certutil) do
  commands :certutil => 'certutil'
  commands :openssl => 'openssl'
  commands :pk12util => 'pk12util'

  def create
    add_certificate
    add_private_key if resource[:private_key]
  end

  def destroy
    if resource[:private_key]
      delete_combined_private_key_and_certificate
    else
      delete_certificate
    end
  end

  def exists?
    nssdb_content
  end

  def certificate
    nssdb_fingerprint
  end

  def certificate=(value)
    unless nssdb_content.nil?
      if resource[:private_key]
        delete_combined_private_key_and_certificate
      else
        delete_certificate
      end
    end
    add_certificate
    add_private_key if resource[:private_key]
  end

  def fingerprint(file)
    return unless File.exist?(file)

    openssl('x509', '-sha256', '-noout', '-fingerprint', '-in', file).strip.split('=')[1]
  rescue Puppet::ExecutionFailure => e
    Puppet.warn("Failed to read certificate #{file}: #{e}")
    nil
  end

  private

  def add_certificate
    certutil(
      '-A',
      '-a',
      '-d', resource[:nssdb],
      '-n', resource[:cert_name],
      '-t', resource[:trustargs],
      '-i', resource[:certificate],
      '-f', resource[:password_file]
    )
  end

  def delete_certificate
    certutil(
      '-D',
      '-d', resource[:nssdb],
      '-n', resource[:cert_name]
    )
  end

  def add_private_key
    Tempfile.open('pkcs12') do |pkcs12|
      openssl(
        'pkcs12',
        '-export',
        '-in', resource[:certificate],
        '-inkey', resource[:private_key],
        '-out', pkcs12.path,
        '-password', "file:#{resource[:password_file]}",
        '-name', resource[:cert_name]
      )

      pk12util(
        '-i', pkcs12.path,
        '-d', resource[:nssdb],
        '-w', resource[:password_file],
        '-k', resource[:password_file]
      )
    end
  end

  def delete_combined_private_key_and_certificate
    certutil(
      '-F',
      '-d', resource[:nssdb],
      '-n', resource[:cert_name],
      '-f', resource[:password_file]
    )
  end

  def nssdb_content
    return unless directory_readable?(resource[:nssdb])

    certutil(
      '-L',
      '-a',
      '-d', resource[:nssdb],
      '-n', resource[:cert_name]
    )
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("Failed to read nssdb contents from #{resource[:nssdb]}: #{e}")
    nil
  end

  def nssdb_fingerprint
    cert_info = nssdb_content
    return unless cert_info

    Tempfile.open('cert') do |temp_cert|
      temp_cert.write(cert_info)
      temp_cert.rewind
      fingerprint(temp_cert.path)
    end
  end

  def directory_readable?(file)
    File.directory?(file) && File.readable?(file)
  end
end
