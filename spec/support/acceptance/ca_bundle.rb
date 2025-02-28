begin
  require 'serverspec'
rescue LoadError
  # Not using acceptance tests
else
  module Serverspec
    module Type
      class CaBundle < Base
        def content
          if @content.nil?
            @content = load_fullchain(@runner.get_file_content(@name).stdout)
          end
          @content
        end

        def exist?
          @runner.check_file_exists(@name)
        end

        def size
          content.length
        end

        def has_cert?(file_path)
          target_cert = OpenSSL::X509::Certificate.new(@runner.get_file_content(file_path).stdout)
          content.any? do |actual_cert|
            target_cert = actual_cert
          end
        end

        def load_fullchain(bundle_pem)
          bundle_pem.
            lines.
            slice_after(/^-----END CERTIFICATE-----/).
            filter { |pem| pem.join.include?('-----END CERTIFICATE-----') }.
            map { |pem| OpenSSL::X509::Certificate.new(pem.join) }
        end
      end
    end

    module Helper
      module Type
        def ca_bundle(*args)
          Serverspec::Type::CaBundle.new(*args)
        end
      end
    end
  end
end
