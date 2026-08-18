require 'openssl'
require 'base64'

module Wsaa
  ##
  # Signs data using CMS/PKCS#7 format.
  #
  # Creates cryptographic signatures compatible with WSAA requirements.
  #
  # @attr_reader certificate [OpenSSL::X509::Certificate] The signing certificate.
  # @attr_reader private_key [OpenSSL::PKey::RSA] The private key for signing.
  class CmsSigner
    attr_reader :certificate, :private_key

    ##
    # Creates a new CmsSigner.
    #
    # @param cert_path [String] Path to the certificate file in PEM format.
    # @param pkey_path [String] Path to the private key file in PEM format.
    # @raise [SigningError] If the certificate or key cannot be loaded.
    def initialize(cert_path:, pkey_path:)
      @certificate = load_certificate(cert_path)
      @private_key = load_private_key(pkey_path)
    end

    ##
    # Signs data and returns the base64-encoded CMS signature.
    #
    # @param data [String] The data to sign.
    # @return [String] Base64-encoded PKCS#7/CMS signature.
    # @raise [SigningError] If signing fails.
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
