# @summary
#   Extracts a certificate's subject in RFC2253 form
#
# @example How to extract a certificate's subject
#   $cert_subject = certs::certificate_subject($path_to_certificate)
#
Puppet::Functions.create_function(:'certs::certificate_subject') do
  # @param certificate_path
  dispatch :certificate_subject do
    param 'String[1]', :certificate_path
    return_type 'Optional[String]'
  end

  def certificate_subject(certificate_path)
    begin
      cert = OpenSSL::X509::Certificate.new(File.read(certificate_path))
      cert.subject.to_s(OpenSSL::X509::Name::RFC2253)
    rescue OpenSSL::X509::CertificateError, Errno::ENOENT => e
      Puppet.debug("The file at #{certificate_path} could not be read or is not a valid x509 certificate: #{e}")
      nil
    end
  end
end
