require_relative 'wsaa/version'
require_relative 'wsaa/errors'
require_relative 'wsaa/configuration'
require_relative 'wsaa/tra'
require_relative 'wsaa/cms_signer'
require_relative 'wsaa/credentials'
require_relative 'wsaa/credential_store'
require_relative 'wsaa/client'

module Wsaa
  class << self
    def configure
      yield(configuration)
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def authenticate
      client.authenticate
    end

    def authenticate!
      client.authenticate!
    end

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
