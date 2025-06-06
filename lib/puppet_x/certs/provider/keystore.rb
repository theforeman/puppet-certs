module PuppetX
  module Certs
    module Provider
      module Keystore
        def create
          generate_keystore
        end

        def destroy
          delete_keystore
        end

        def exists?
          return false unless File.exist?(store)

          begin
            keytool(
              '-list',
              '-keystore', store,
              '-storepass:file', resource[:password_file],
              '-J-Dcom.redhat.fips=false',
            )
          rescue Puppet::ExecutionFailure => e
            if e.message.include?('java.security.UnrecoverableKeyException') || e.message.include?('keystore password was incorrect')
              Puppet.debug("Invalid password for #{store}")
              return false
            elsif e.message.include?('Keystore file exists, but is empty')
              Puppet.debug(e)
              return false
            else
              Puppet.log_exception(e, "Failed to read keystore '#{store}'")
            end
          end

          true
        end

        def store
          resource[:keystore]
        end

        def type
          'keystore'
        end

        def generate_keystore
          temp_alias = 'temporary-entry'

          delete_keystore

          begin
            keytool(
              '-genkey',
              '-storetype', 'pkcs12',
              '-keystore', store,
              '-storepass:file', resource[:password_file],
              '-alias', temp_alias,
              '-dname', "CN=#{temp_alias}",
              '-J-Dcom.redhat.fips=false',
              '-keyalg', 'RSA'
            )
          rescue Puppet::ExecutionFailure => e
            Puppet.err("Failed to generate new #{type} with temporary entry: #{e}")
            return nil
          end

          begin
            keytool(
              '-delete',
              '-keystore', store,
              '-storepass:file', resource[:password_file],
              '-alias', temp_alias,
              '-J-Dcom.redhat.fips=false'
            )
          rescue Puppet::ExecutionFailure => e
            Puppet.err("Failed to delete temporary entry when generating empty #{type}: #{e}")
            return nil
          end
        end

        def delete_keystore
          FileUtils.rm_f(store)
        end
      end
    end
  end
end
