# @summary
#   Extracts a certificate's subject in RFC2253 form
#
# @example How to extract a certificate's subject
#   $cert_subject = certs::certificate_subject($path_to_certificate)
#
Puppet::Functions.create_function(:'certs::certificate_subject') do
  # @param certificate_path
  # @param include_spaces
  #   When true, generates subject in RFC2253 format with a space between each element.
  #   This is equivalent to specifying openssl x509 -in <certificate_path> -nameopt RFC2253,sep_comma_plus_space
  dispatch :certificate_subject do
    required_param 'String[1]', :certificate_path
    optional_param 'Optional[Boolean]', :include_spaces
    return_type 'Optional[String]'
  end

  def certificate_subject(certificate_path, include_spaces = false)
    unless File.exist?(certificate_path)
      Puppet.err("The file at #{certificate_path} does not exist, the certificate subject could not be calculated.")
    end

    begin
      cert = OpenSSL::X509::Certificate.new(File.read(certificate_path))
      subject = cert.subject.to_s(OpenSSL::X509::Name::RFC2253)
      subject = subject.split(',').join(', ') if include_spaces
      subject
    rescue OpenSSL::X509::CertificateError, Errno::ENOENT => e
      Puppet.debug("The file at #{certificate_path} could not be read or is not a valid x509 certificate: #{e}")
      nil
    end
  end
end
