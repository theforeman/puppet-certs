begin
  require 'serverspec'
rescue LoadError
  # Not using acceptance tests
else
  module Serverspec
    module Type
      class Tar < Command
        def contents
          command_result.stdout.split("\n")
        end

        def exist?
          @runner.check_file_exists(@name)
        end

        private

        def command
          "tar -tf #{@name}"
        end

        def command_result
          @command_result ||= @runner.run_command(command)
        end
      end
    end

    module Helper
      module Type
        def tar(*args)
          Serverspec::Type::Tar.new(*args)
        end
      end
    end
  end
end
