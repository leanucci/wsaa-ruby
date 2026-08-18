module Wsaa
  ##
  # Holds configuration for the WSAA client.
  #
  # @attr_accessor pkey [String] Path to the private key file.
  # @attr_accessor cert [String] Path to the certificate file.
  # @attr_accessor service [String] The AFIP service to authenticate for.
  # @attr_accessor environment [Symbol] The environment (:testing or :production).
  # @attr_accessor cache_dir [String] Directory for credential caching.
  class Configuration
    ENDPOINTS = {
      testing: 'https://wsaahomo.afip.gov.ar/ws/services/LoginCms',
      production: 'https://wsaa.afip.gov.ar/ws/services/LoginCms'
    }.freeze

    attr_accessor :pkey, :cert, :service, :environment, :cache_dir

    ##
    # Creates a new Configuration with default values.
    def initialize
      @environment = :testing
      @service = 'wsfe'
      @cache_dir = '/tmp'
    end

    ##
    # Returns the WSAA endpoint URL for the current environment.
    #
    # @return [String] The endpoint URL.
    # @raise [ConfigurationError] If the environment is invalid.
    def endpoint
      ENDPOINTS.fetch(environment) do
        raise ConfigurationError, "Invalid environment: #{environment}. Must be :testing or :production"
      end
    end

    ##
    # Validates the configuration.
    #
    # @return [true] If the configuration is valid.
    # @raise [ConfigurationError] If required values are missing or files do not exist.
    def validate!
      raise ConfigurationError, "Private key path not configured" if pkey.nil? || pkey.empty?
      raise ConfigurationError, "Certificate path not configured" if cert.nil? || cert.empty?
      raise ConfigurationError, "Private key file not found: #{pkey}" unless File.exist?(pkey)
      raise ConfigurationError, "Certificate file not found: #{cert}" unless File.exist?(cert)
      true
    end
  end
end
