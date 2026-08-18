require 'spec_helper'
require 'rexml/document'

RSpec.describe Wsaa::Tra do
  let(:service) { 'wsfe' }
  subject(:tra) { described_class.new(service: service) }

  describe '#to_xml' do
    let(:xml) { tra.to_xml }
    let(:doc) { REXML::Document.new(xml) }

    it 'generates valid XML with declaration' do
      expect(xml).to start_with("<?xml version='1.0' encoding='UTF-8'?>")
    end

    it 'includes loginTicketRequest root element with version' do
      root = doc.root
      expect(root.name).to eq('loginTicketRequest')
      expect(root.attributes['version']).to eq('1.0')
    end

    it 'includes uniqueId as integer' do
      unique_id = doc.get_text('//uniqueId').to_s
      expect(unique_id).to match(/^\d+$/)
    end

    it 'includes generationTime in ISO 8601 format with timezone' do
      generation_time = doc.get_text('//generationTime').to_s
      expect(generation_time).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/)
    end

    it 'includes expirationTime in ISO 8601 format with timezone' do
      expiration_time = doc.get_text('//expirationTime').to_s
      expect(expiration_time).to match(/^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}[+-]\d{2}:\d{2}$/)
    end

    it 'includes the configured service name' do
      service_element = doc.get_text('//service').to_s
      expect(service_element).to eq('wsfe')
    end
  end

  describe 'default time boundaries' do
    it 'sets generationTime to start of day' do
      expect(tra.generation_time.hour).to eq(0)
      expect(tra.generation_time.min).to eq(0)
      expect(tra.generation_time.sec).to eq(0)
    end

    it 'sets expirationTime to end of day' do
      expect(tra.expiration_time.hour).to eq(23)
      expect(tra.expiration_time.min).to eq(59)
      expect(tra.expiration_time.sec).to eq(59)
    end
  end

  describe 'custom parameters' do
    let(:custom_generation) { Time.new(2024, 1, 15, 10, 30, 0, '-03:00') }
    let(:custom_expiration) { Time.new(2024, 1, 15, 18, 0, 0, '-03:00') }
    let(:custom_id) { 12345 }

    subject(:tra) do
      described_class.new(
        service: 'wsmtxca',
        generation_time: custom_generation,
        expiration_time: custom_expiration,
        unique_id: custom_id
      )
    end

    it 'uses custom service' do
      doc = REXML::Document.new(tra.to_xml)
      expect(doc.get_text('//service').to_s).to eq('wsmtxca')
    end

    it 'uses custom unique_id' do
      expect(tra.unique_id).to eq(12345)
    end

    it 'uses custom generation_time' do
      expect(tra.generation_time).to eq(custom_generation)
    end

    it 'uses custom expiration_time' do
      expect(tra.expiration_time).to eq(custom_expiration)
    end
  end
end
