begin
  require 'serverspec'
rescue LoadError
  # Not using acceptance tests
else
  module Serverspec
    module Type
      class Nssdb < Command
        def certificates
          # TODO: parse the output
          stdout
        end

        private

        def command
          "certutil -L -d #{@name}"
        end
      end

      class NssdbCertificate < Command
        def subject
          # TODO: multi line support
          if command_result =~ /^Subject: (.+)$/
            $1
          end
        end

        def issuer
          # TODO: multi line support
          if command_result =~ /^Issuer: (.+)$/
            $1
          end
        end

        private

        def command
          # TODO: ensure name is set
          "certutil -L -d #{@name} -n #{options[:name]}"
        end
      end
    end

    module Helper
      module Type
        def nssdb(*args)
          Serverspec::Type::Nssdb.new(*args)
        end

        def nssdb_certificate(*args)
          Serverspec::Type::NssdbCertificate.new(*args)
        end
      end
    end
  end
end
