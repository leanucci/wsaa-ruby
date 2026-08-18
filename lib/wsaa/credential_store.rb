require 'yaml'
require 'time'

module Wsaa
  ##
  # File-based cache for WSAA credentials.
  #
  # Stores credentials as YAML files with date-based filenames.
  #
  # @attr_reader cache_dir [String] Directory where cache files are stored.
  # @attr_reader service [String] The service name used in the cache filename.
  class CredentialStore
    attr_reader :cache_dir, :service

    ##
    # Creates a new CredentialStore.
    #
    # @param cache_dir [String] Directory for cache files.
    # @param service [String] The service name.
    def initialize(cache_dir:, service:)
      @cache_dir = cache_dir
      @service = service
    end

    ##
    # Reads cached credentials.
    #
    # @return [Credentials, nil] The cached credentials, or nil if not found or expired.
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

    ##
    # Writes credentials to the cache.
    #
    # @param credentials [Credentials] The credentials to cache.
    # @return [Credentials] The same credentials object.
    def write(credentials)
      File.write(cache_file_path, YAML.dump(credentials.to_h.transform_keys(&:to_s)))
      credentials
    end

    ##
    # Deletes the cache file.
    def clear
      File.delete(cache_file_path) if File.exist?(cache_file_path)
    end

    ##
    # Returns the full path to the cache file.
    #
    # @return [String] The cache file path.
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
