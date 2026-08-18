module Wsaa
  ##
  # Base error class for all WSAA errors.
  class Error < StandardError; end

  ##
  # Raised when the configuration is invalid or incomplete.
  class ConfigurationError < Error; end

  ##
  # Raised when CMS/PKCS#7 signing fails.
  class SigningError < Error; end

  ##
  # Raised when WSAA authentication fails.
  #
  # @attr_reader fault_code [String, nil] The SOAP fault code from WSAA.
  # @attr_reader fault_string [String, nil] The SOAP fault message from WSAA.
  class AuthenticationError < Error
    attr_reader :fault_code, :fault_string

    ##
    # Creates a new AuthenticationError.
    #
    # @param message [String] The error message.
    # @param fault_code [String, nil] The SOAP fault code.
    # @param fault_string [String, nil] The SOAP fault message.
    def initialize(message, fault_code: nil, fault_string: nil)
      @fault_code = fault_code
      @fault_string = fault_string
      super(message)
    end
  end
end
