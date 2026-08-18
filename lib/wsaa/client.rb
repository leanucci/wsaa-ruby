require 'savon'
require 'rexml/document'

module Wsaa
  class Client
    attr_reader :configuration

    def initialize(configuration)
      @configuration = configuration
    end

    def authenticate
      configuration.validate!

      cached = credential_store.read
      return cached if cached

      authenticate!
    end

    def authenticate!
      configuration.validate!

      tra = build_tra
      signed_tra = sign_tra(tra.to_xml)
      response = call_wsaa(signed_tra)
      credentials = parse_response(response, tra.expiration_time)

      credential_store.write(credentials)
      credentials
    end

    private

    def build_tra
      Tra.new(service: configuration.service)
    end

    def sign_tra(tra_xml)
      signer = CmsSigner.new(
        cert_path: configuration.cert,
        pkey_path: configuration.pkey
      )
      signer.sign(tra_xml)
    end

    def call_wsaa(signed_tra)
      client = Savon.client(
        wsdl: "#{configuration.endpoint}?WSDL",
        endpoint: configuration.endpoint,
        ssl_verify_mode: :none,
        log: false
      )

      client.call(:login_cms, message: { in0: signed_tra })
    rescue Savon::SOAPFault => e
      raise AuthenticationError.new(
        "WSAA authentication failed: #{e.message}",
        fault_code: e.to_hash.dig(:fault, :faultcode),
        fault_string: e.to_hash.dig(:fault, :faultstring)
      )
    rescue Savon::Error => e
      raise AuthenticationError, "WSAA request failed: #{e.message}"
    end

    def parse_response(response, expiration_time)
      login_cms_return = response.body.dig(:login_cms_response, :login_cms_return)

      raise AuthenticationError, "Empty response from WSAA" if login_cms_return.nil?

      doc = REXML::Document.new(login_cms_return)
      token = doc.get_text('//token')&.to_s
      sign = doc.get_text('//sign')&.to_s

      if token.nil? || token.empty? || sign.nil? || sign.empty?
        raise AuthenticationError, "Invalid response: missing token or sign"
      end

      Credentials.new(
        token: token,
        sign: sign,
        expiration_time: expiration_time
      )
    end

    def credential_store
      @credential_store ||= CredentialStore.new(
        cache_dir: configuration.cache_dir,
        service: configuration.service
      )
    end
  end
end
