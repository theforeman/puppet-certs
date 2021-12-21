Puppet::Type.type(:private_key).provide(:openssl) do
  commands :openssl => 'openssl'

  def create
    File.write(resource[:path], private_key_content)
  end

  def destroy
    delete_private_key
  end

  def exists?
    File.exist?(resource[:path]) && File.read(resource[:path]) == private_key_content
  end

  private

  def private_key_content
    key_path = full_path(resource[:source][0])

    if resource[:decrypt]
      decrypt(key_path, resource[:password_file])
    else
      File.read(key_path)
    end
  end

  def delete_private_key
    File.unlink(resource[:path])
  end

  def full_path(source)
    Puppet::Util.uri_to_path(URI.parse(Puppet::Util.uri_encode(source)))
  end

  def decrypt(path, password_file)
    openssl(
      'rsa',
      '-in', path,
      '-passin', "file:#{password_file}",
      '-text'
    )
  end

end
