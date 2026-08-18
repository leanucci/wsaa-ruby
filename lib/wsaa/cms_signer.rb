require 'openssl'
require 'base64'

module Wsaa
  class CmsSigner
    attr_reader :certificate, :private_key

    def initialize(cert_path:, pkey_path:)
      @certificate = load_certificate(cert_path)
      @private_key = load_private_key(pkey_path)
    end

    def sign(data)
      flags = OpenSSL::PKCS7::BINARY | OpenSSL::PKCS7::NOSMIMECAP
      pkcs7 = OpenSSL::PKCS7.sign(certificate, private_key, data, [], flags)
      Base64.strict_encode64(pkcs7.to_der)
    rescue OpenSSL::PKCS7::PKCS7Error => e
      raise SigningError, "Failed to sign data: #{e.message}"
    end

    private

    def load_certificate(path)
      OpenSSL::X509::Certificate.new(File.read(path))
    rescue OpenSSL::X509::CertificateError => e
      raise SigningError, "Invalid certificate: #{e.message}"
    rescue Errno::ENOENT
      raise SigningError, "Certificate file not found: #{path}"
    end

    def load_private_key(path)
      OpenSSL::PKey::RSA.new(File.read(path))
    rescue OpenSSL::PKey::RSAError => e
      raise SigningError, "Invalid private key: #{e.message}"
    rescue Errno::ENOENT
      raise SigningError, "Private key file not found: #{path}"
    end
  end
end
