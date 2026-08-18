module Wsaa
  class Credentials
    attr_reader :token, :sign, :expiration_time

    def initialize(token:, sign:, expiration_time:)
      @token = token.freeze
      @sign = sign.freeze
      @expiration_time = expiration_time
      freeze
    end

    def expired?
      Time.now > expiration_time
    end

    def valid?
      !expired? && !token.nil? && !sign.nil?
    end

    def to_h
      {
        token: token,
        sign: sign,
        expiration_time: expiration_time.iso8601
      }
    end
  end
end
