module Wsaa
  class Configuration
    ENDPOINTS = {
      testing: 'https://wsaahomo.afip.gov.ar/ws/services/LoginCms',
      production: 'https://wsaa.afip.gov.ar/ws/services/LoginCms'
    }.freeze

    attr_accessor :pkey, :cert, :service, :environment, :cache_dir

    def initialize
      @environment = :testing
      @service = 'wsfe'
      @cache_dir = '/tmp'
    end

    def endpoint
      ENDPOINTS.fetch(environment) do
        raise ConfigurationError, "Invalid environment: #{environment}. Must be :testing or :production"
      end
    end

    def validate!
      raise ConfigurationError, "Private key path not configured" if pkey.nil? || pkey.empty?
      raise ConfigurationError, "Certificate path not configured" if cert.nil? || cert.empty?
      raise ConfigurationError, "Private key file not found: #{pkey}" unless File.exist?(pkey)
      raise ConfigurationError, "Certificate file not found: #{cert}" unless File.exist?(cert)
      true
    end
  end
end
