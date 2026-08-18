require 'spec_helper'

RSpec.describe Wsaa::Configuration do
  subject(:config) { described_class.new }

  describe 'defaults' do
    it 'sets default environment to :testing' do
      expect(config.environment).to eq(:testing)
    end

    it 'sets default service to wsfe' do
      expect(config.service).to eq('wsfe')
    end

    it 'sets default cache_dir to /tmp' do
      expect(config.cache_dir).to eq('/tmp')
    end
  end

  describe '#endpoint' do
    it 'returns testing URL for :testing environment' do
      config.environment = :testing
      expect(config.endpoint).to eq('https://wsaahomo.afip.gov.ar/ws/services/LoginCms')
    end

    it 'returns production URL for :production environment' do
      config.environment = :production
      expect(config.endpoint).to eq('https://wsaa.afip.gov.ar/ws/services/LoginCms')
    end

    it 'raises ConfigurationError for invalid environment' do
      config.environment = :invalid
      expect { config.endpoint }.to raise_error(Wsaa::ConfigurationError, /Invalid environment/)
    end
  end

  describe '#validate!' do
    context 'with valid configuration' do
      before do
        config.pkey = fixture_path('test_key.pem')
        config.cert = fixture_path('test_cert.pem')
      end

      it 'returns true' do
        expect(config.validate!).to be true
      end
    end

    context 'with missing pkey' do
      before { config.cert = fixture_path('test_cert.pem') }

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Wsaa::ConfigurationError, /Private key path not configured/)
      end
    end

    context 'with missing cert' do
      before { config.pkey = fixture_path('test_key.pem') }

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Wsaa::ConfigurationError, /Certificate path not configured/)
      end
    end

    context 'with non-existent pkey file' do
      before do
        config.pkey = '/nonexistent/path/key.pem'
        config.cert = fixture_path('test_cert.pem')
      end

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Wsaa::ConfigurationError, /Private key file not found/)
      end
    end

    context 'with non-existent cert file' do
      before do
        config.pkey = fixture_path('test_key.pem')
        config.cert = '/nonexistent/path/cert.pem'
      end

      it 'raises ConfigurationError' do
        expect { config.validate! }.to raise_error(Wsaa::ConfigurationError, /Certificate file not found/)
      end
    end
  end
end
