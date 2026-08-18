require 'rexml/document'

module Wsaa
  ##
  # Builds the Ticket de Requerimiento de Acceso (TRA) XML document.
  #
  # The TRA is the access request ticket required by WSAA for authentication.
  #
  # @attr_reader service [String] The AFIP service name.
  # @attr_reader generation_time [Time] When the TRA was generated.
  # @attr_reader expiration_time [Time] When the TRA expires.
  # @attr_reader unique_id [Integer] Unique identifier for the request.
  class Tra
    TIMEZONE_OFFSET = '-03:00'

    attr_reader :service, :generation_time, :expiration_time, :unique_id

    ##
    # Creates a new TRA.
    #
    # @param service [String] The AFIP service to authenticate for.
    # @param generation_time [Time, nil] Start of validity period. Defaults to today 00:00:00.
    # @param expiration_time [Time, nil] End of validity period. Defaults to today 23:59:59.
    # @param unique_id [Integer, nil] Unique request identifier. Defaults to current timestamp.
    def initialize(service:, generation_time: nil, expiration_time: nil, unique_id: nil)
      @service = service
      @unique_id = unique_id || Time.now.to_i
      @generation_time = generation_time || default_generation_time
      @expiration_time = expiration_time || default_expiration_time
    end

    ##
    # Converts the TRA to an XML string.
    #
    # @return [String] The TRA as XML.
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
