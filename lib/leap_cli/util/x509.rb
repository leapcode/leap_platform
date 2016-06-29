autoload :OpenSSL, 'openssl'
autoload :CertificateAuthority, 'certificate_authority'

require 'digest'
require 'digest/md5'
require 'digest/sha1'

module LeapCli; module X509
  extend self

  #
  # returns a fingerprint of a x509 certificate
  #
  def fingerprint(digest, cert_file)
    if cert_file.is_a? String
      cert = OpenSSL::X509::Certificate.new(Util.read_file!(cert_file))
    elsif cert_file.is_a? OpenSSL::X509::Certificate
      cert = cert_file
    elsif cert_file.is_a? CertificateAuthority::Certificate
      cert = cert_file.openssl_body
    end
    digester = case digest
      when "MD5" then Digest::MD5.new
      when "SHA1" then Digest::SHA1.new
      when "SHA256" then Digest::SHA256.new
      when "SHA384" then Digest::SHA384.new
      when "SHA512" then Digest::SHA512.new
    end
    digester.hexdigest(cert.to_der)
  end


end; end
