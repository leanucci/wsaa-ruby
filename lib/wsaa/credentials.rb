module Wsaa
  ##
  # Immutable value object for WSAA authentication credentials.
  #
  # Holds the TOKEN and SIGN values returned by WSAA after successful authentication.
  #
  # @attr_reader token [String] The authentication token.
  # @attr_reader sign [String] The authentication signature.
  # @attr_reader expiration_time [Time] When the credentials expire.
  class Credentials
    attr_reader :token, :sign, :expiration_time

    ##
    # Creates new Credentials.
    #
    # @param token [String] The authentication token from WSAA.
    # @param sign [String] The authentication signature from WSAA.
    # @param expiration_time [Time] When the credentials expire.
    def initialize(token:, sign:, expiration_time:)
      @token = token.freeze
      @sign = sign.freeze
      @expiration_time = expiration_time
      freeze
    end

    ##
    # Checks if the credentials have expired.
    #
    # @return [Boolean] True if expired.
    def expired?
      Time.now > expiration_time
    end

    ##
    # Checks if the credentials are valid.
    #
    # @return [Boolean] True if not expired and has token and sign.
    def valid?
      !expired? && !token.nil? && !sign.nil?
    end

    ##
    # Converts credentials to a hash.
    #
    # @return [Hash] Hash with :token, :sign, and :expiration_time keys.
    def to_h
      {
        token: token,
        sign: sign,
        expiration_time: expiration_time.iso8601
      }
    end
  end
end
