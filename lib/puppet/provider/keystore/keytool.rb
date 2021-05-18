Puppet::Type.type(:keystore).provide(:keytool) do
  commands :keytool => 'keytool'

  def create
    generate_keystore
  end

  def destroy
    delete_keystore
  end

  def exists?
    File.exist?(resource[:keystore])
  end

  private

  def generate_keystore
    temp_alias = 'temporary-entry'

    begin
      keytool(
        '-genkey',
        '-storetype', 'pkcs12',
        '-keystore', resource[:keystore],
        '-storepass:file', resource[:password_file],
        '-alias', temp_alias,
        '-dname', "CN=#{temp_alias}"
      )
    rescue Puppet::ExecutionFailure => e
      Puppet.error("Failed to generate new keystore with temporary entry: #{e}")
      return nil
    end

    begin
      keytool(
        '-delete',
        '-keystore', resource[:keystore],
        '-storepass:file', resource[:password_file],
        '-alias', temp_alias
      )
    rescue Puppet::ExecutionFailure => e
      Puppet.error("Failed to delete temporary entry when generating empty keystore: #{e}")
      return nil
    end
  end

  def delete_keystore
    File.rm(resource[:keystore])
  end
end
