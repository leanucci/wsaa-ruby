require_relative 'wsaa/version'
require_relative 'wsaa/errors'
require_relative 'wsaa/configuration'
require_relative 'wsaa/tra'
require_relative 'wsaa/cms_signer'
require_relative 'wsaa/credentials'
require_relative 'wsaa/credential_store'
require_relative 'wsaa/client'

##
# Main module for WSAA authentication.
#
# Provides a simple interface to authenticate with AFIP's WSAA service.
#
# @example Configure and authenticate
#   Wsaa.configure do |config|
#     config.pkey = 'path/to/private_key'
#     config.cert = 'path/to/certificate'
#     config.service = 'wsfe'
#     config.environment = :testing
#   end
#
#   credentials = Wsaa.authenticate
#   credentials.token  # => "PD94bWwg..."
#   credentials.sign   # => "GGG2XMe..."
module Wsaa
  class << self
    ##
    # Configures the WSAA client.
    #
    # @yield [Configuration] The configuration object.
    #
    # @example
    #   Wsaa.configure do |config|
    #     config.pkey = 'path/to/key'
    #     config.cert = 'path/to/cert'
    #   end
    def configure
      yield(configuration)
    end

    ##
    # Returns the current configuration.
    #
    # @return [Configuration] The configuration object.
    def configuration
      @configuration ||= Configuration.new
    end

    ##
    # Authenticates with WSAA using cached credentials if available.
    #
    # @return [Credentials] The authentication credentials.
    # @raise [ConfigurationError] If the configuration is invalid.
    # @raise [AuthenticationError] If authentication fails.
    def authenticate
      client.authenticate
    end

    ##
    # Authenticates with WSAA, ignoring any cached credentials.
    #
    # @return [Credentials] The authentication credentials.
    # @raise [ConfigurationError] If the configuration is invalid.
    # @raise [AuthenticationError] If authentication fails.
    def authenticate!
      client.authenticate!
    end

    ##
    # Resets the configuration and client state.
    def reset!
      @configuration = nil
      @client = nil
    end

    private

    def client
      @client ||= Client.new(configuration)
    end
  end
end
