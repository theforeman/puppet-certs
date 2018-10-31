# Validate that the file exists.
#
# This function can work only when running puppet apply.
# @todo Find a way how to skip it for puppetmaster scenario.
Puppet::Functions.create_function(:validate_file_exists) do
  # @param files Files to verify
  # @return true when all files exist, an exception otherwise
  dispatch :validate_file_exists do
    required_repeated_param 'Stdlib::Absolutepath', :files
    return_type 'Boolean'
  end

  def validate_file_exists(*files)
    files.each do |file|
      raise Puppet::Error, "#{file} does not exist" unless File.exist?(file)
    end

    true
  end
end
