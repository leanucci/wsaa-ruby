module Wsaa
  class Error < StandardError; end

  class ConfigurationError < Error; end

  class SigningError < Error; end

  class AuthenticationError < Error
    attr_reader :fault_code, :fault_string

    def initialize(message, fault_code: nil, fault_string: nil)
      @fault_code = fault_code
      @fault_string = fault_string
      super(message)
    end
  end
end
