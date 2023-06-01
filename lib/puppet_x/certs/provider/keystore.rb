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
          File.exist?(store)
        end

        def store
          resource[:keystore]
        end

        def type
          'keystore'
        end

        def generate_keystore
          temp_alias = 'temporary-entry'

          begin
            keytool(
              '-genkey',
              '-storetype', 'pkcs12',
              '-keystore', store,
              '-storepass:file', resource[:password_file],
              '-alias', temp_alias,
              '-dname', "CN=#{temp_alias}",
              '-J-Dcom.redhat.fips=false'
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
          File.rm(store)
        end
      end
    end
  end
end
