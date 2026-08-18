require 'spec_helper'

RSpec.describe Wsaa do
  describe '.configure' do
    it 'yields configuration block' do
      expect { |b| described_class.configure(&b) }.to yield_with_args(Wsaa::Configuration)
    end

    it 'allows setting configuration values' do
      described_class.configure do |config|
        config.service = 'wsmtxca'
        config.environment = :production
      end

      expect(described_class.configuration.service).to eq('wsmtxca')
      expect(described_class.configuration.environment).to eq(:production)
    end
  end

  describe '.configuration' do
    it 'returns a Configuration object' do
      expect(described_class.configuration).to be_a(Wsaa::Configuration)
    end

    it 'returns the same instance on multiple calls' do
      expect(described_class.configuration).to be(described_class.configuration)
    end
  end

  describe '.reset!' do
    it 'clears configuration' do
      described_class.configure { |c| c.service = 'custom' }
      described_class.reset!
      expect(described_class.configuration.service).to eq('wsfe')
    end
  end

  describe '.authenticate' do
    it 'delegates to Client#authenticate' do
      described_class.configure do |config|
        config.pkey = fixture_path('test_key.pem')
        config.cert = fixture_path('test_cert.pem')
      end

      client_instance = instance_double(Wsaa::Client)
      allow(Wsaa::Client).to receive(:new).and_return(client_instance)
      expect(client_instance).to receive(:authenticate)

      described_class.authenticate
    end
  end

  describe '.authenticate!' do
    it 'delegates to Client#authenticate!' do
      described_class.configure do |config|
        config.pkey = fixture_path('test_key.pem')
        config.cert = fixture_path('test_cert.pem')
      end

      client_instance = instance_double(Wsaa::Client)
      allow(Wsaa::Client).to receive(:new).and_return(client_instance)
      expect(client_instance).to receive(:authenticate!)

      described_class.authenticate!
    end
  end

  describe 'VERSION' do
    it 'is defined' do
      expect(Wsaa::VERSION).not_to be_nil
    end

    it 'follows semantic versioning' do
      expect(Wsaa::VERSION).to match(/^\d+\.\d+\.\d+/)
    end
  end
end
