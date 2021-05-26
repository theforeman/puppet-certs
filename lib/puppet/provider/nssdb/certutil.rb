require 'fileutils'

Puppet::Type.type(:nssdb).provide(:certutil) do
  commands :certutil => 'certutil'

  def create
    destroy_nssdb
    create_nssdb_dir
    generate_nssdb
  end

  def destroy
    destroy_nssdb
  end

  def exists?
    nssdb_exists?
  end

  private

  def create_nssdb_dir
    FileUtils.mkdir_p(resource[:nssdb_dir])
  end

  def generate_nssdb
    certutil(
      '-N',
      '-d', resource[:nssdb_dir],
      '-f', resource[:password_file]
    )
  rescue Puppet::ExecutionFailure => e
    raise Puppet::Error.new("Failed to generate new NSS database at #{resource[:nssdb_dir]} with password file #{resource[:password_file]}: #{e}", e)
  end

  def destroy_nssdb
    FileUtils.rm_rf(resource[:nssdb_dir], secure: true)
  end

  def nssdb_exists?
    certutil(
      '-K',
      '-d', resource[:nssdb_dir],
      '-f', resource[:password_file]
    )
  rescue Puppet::ExecutionFailure => e
    Puppet.debug("Unable to verify NSS database at #{resource[:nssdb_dir]} with password file #{resource[:password_file]}: #{e}")
    return false
  end
end
