require 'rexml/document'

module Wsaa
  class Tra
    TIMEZONE_OFFSET = '-03:00'

    attr_reader :service, :generation_time, :expiration_time, :unique_id

    def initialize(service:, generation_time: nil, expiration_time: nil, unique_id: nil)
      @service = service
      @unique_id = unique_id || Time.now.to_i
      @generation_time = generation_time || default_generation_time
      @expiration_time = expiration_time || default_expiration_time
    end

    def to_xml
      doc = REXML::Document.new
      doc << REXML::XMLDecl.new('1.0', 'UTF-8')

      root = doc.add_element('loginTicketRequest', 'version' => '1.0')

      header = root.add_element('header')
      header.add_element('uniqueId').text = unique_id.to_s
      header.add_element('generationTime').text = format_time(generation_time)
      header.add_element('expirationTime').text = format_time(expiration_time)

      root.add_element('service').text = service

      output = String.new
      doc.write(output)
      output
    end

    private

    def default_generation_time
      today = Time.now
      Time.new(today.year, today.month, today.day, 0, 0, 0, TIMEZONE_OFFSET)
    end

    def default_expiration_time
      today = Time.now
      Time.new(today.year, today.month, today.day, 23, 59, 59, TIMEZONE_OFFSET)
    end

    def format_time(time)
      time.strftime('%Y-%m-%dT%H:%M:%S%:z')
    end
  end
end
