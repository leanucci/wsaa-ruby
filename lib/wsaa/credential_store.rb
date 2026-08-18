require 'yaml'
require 'time'

module Wsaa
  class CredentialStore
    attr_reader :cache_dir, :service

    def initialize(cache_dir:, service:)
      @cache_dir = cache_dir
      @service = service
    end

    def read
      return nil unless File.exist?(cache_file_path)

      data = YAML.load_file(cache_file_path)
      expiration_time = parse_expiration_time(data['expiration_time'])

      credentials = Credentials.new(
        token: data['token'],
        sign: data['sign'],
        expiration_time: expiration_time
      )

      credentials.valid? ? credentials : nil
    rescue StandardError
      nil
    end

    def write(credentials)
      File.write(cache_file_path, YAML.dump(credentials.to_h.transform_keys(&:to_s)))
      credentials
    end

    def clear
      File.delete(cache_file_path) if File.exist?(cache_file_path)
    end

    def cache_file_path
      File.join(cache_dir, cache_filename)
    end

    private

    def cache_filename
      date_str = Time.now.strftime('%d_%m_%Y')
      "wsaa_#{service}_#{date_str}.yml"
    end

    def parse_expiration_time(value)
      case value
      when Time then value
      when String then Time.parse(value)
      else raise ArgumentError, "Invalid expiration_time: #{value}"
      end
    end
  end
end
