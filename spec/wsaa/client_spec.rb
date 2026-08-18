require 'spec_helper'
require 'tmpdir'

RSpec.describe Wsaa::Client do
  let(:cache_dir) { Dir.mktmpdir }
  let(:configuration) do
    config = Wsaa::Configuration.new
    config.pkey = fixture_path('test_key.pem')
    config.cert = fixture_path('test_cert.pem')
    config.service = 'wsfe'
    config.cache_dir = cache_dir
    config
  end

  subject(:client) { described_class.new(configuration) }

  after { FileUtils.remove_entry(cache_dir) }

  describe '#authenticate' do
    context 'with cached valid credentials' do
      let(:cached_credentials) do
        Wsaa::Credentials.new(
          token: 'cached_token',
          sign: 'cached_sign',
          expiration_time: Time.now + 3600
        )
      end

      before do
        store = Wsaa::CredentialStore.new(cache_dir: cache_dir, service: 'wsfe')
        store.write(cached_credentials)
      end

      it 'returns cached credentials without calling WSAA' do
        expect(client).not_to receive(:call_wsaa)
        result = client.authenticate
        expect(result.token).to eq('cached_token')
      end
    end

    context 'without cached credentials' do
      let(:wsaa_response_xml) do
        <<~XML
          <?xml version="1.0" encoding="UTF-8"?>
          <loginTicketResponse>
            <credentials>
              <token>fresh_token</token>
              <sign>fresh_sign</sign>
            </credentials>
          </loginTicketResponse>
        XML
      end

      let(:savon_response) do
        double('Savon::Response', body: {
          login_cms_response: {
            login_cms_return: wsaa_response_xml
          }
        })
      end

      let(:savon_client) { double('Savon::Client') }

      before do
        allow(Savon).to receive(:client).and_return(savon_client)
        allow(savon_client).to receive(:call).and_return(savon_response)
      end

      it 'builds TRA with correct service' do
        expect(Wsaa::Tra).to receive(:new).with(service: 'wsfe').and_call_original
        client.authenticate
      end

      it 'calls loginCms SOAP operation' do
        expect(savon_client).to receive(:call).with(:login_cms, hash_including(:message))
        client.authenticate
      end

      it 'returns Credentials object' do
        expect(client.authenticate).to be_a(Wsaa::Credentials)
      end

      it 'parses token from response' do
        expect(client.authenticate.token).to eq('fresh_token')
      end

      it 'parses sign from response' do
        expect(client.authenticate.sign).to eq('fresh_sign')
      end

      it 'caches new credentials' do
        client.authenticate
        store = Wsaa::CredentialStore.new(cache_dir: cache_dir, service: 'wsfe')
        expect(store.read).not_to be_nil
      end
    end

    context 'with SOAP error' do
      before do
        savon_client = double('Savon::Client')
        allow(Savon).to receive(:client).and_return(savon_client)
        allow(savon_client).to receive(:call).and_raise(Savon::Error.new('Connection refused'))
      end

      it 'raises AuthenticationError' do
        expect { client.authenticate }.to raise_error(Wsaa::AuthenticationError, /WSAA request failed/)
      end
    end

    context 'with invalid configuration' do
      let(:configuration) do
        config = Wsaa::Configuration.new
        config.pkey = nil
        config
      end

      it 'raises ConfigurationError' do
        expect { client.authenticate }.to raise_error(Wsaa::ConfigurationError)
      end
    end
  end

  describe '#authenticate!' do
    let(:wsaa_response_xml) do
      <<~XML
        <?xml version="1.0" encoding="UTF-8"?>
        <loginTicketResponse>
          <credentials>
            <token>new_token</token>
            <sign>new_sign</sign>
          </credentials>
        </loginTicketResponse>
      XML
    end

    let(:savon_response) do
      double('Savon::Response', body: {
        login_cms_response: {
          login_cms_return: wsaa_response_xml
        }
      })
    end

    let(:savon_client) { double('Savon::Client') }

    before do
      allow(Savon).to receive(:client).and_return(savon_client)
      allow(savon_client).to receive(:call).and_return(savon_response)
    end

    it 'forces re-authentication ignoring cache' do
      # First, cache some credentials
      cached_credentials = Wsaa::Credentials.new(
        token: 'cached_token',
        sign: 'cached_sign',
        expiration_time: Time.now + 3600
      )
      store = Wsaa::CredentialStore.new(cache_dir: cache_dir, service: 'wsfe')
      store.write(cached_credentials)

      # authenticate! should ignore cache and fetch new credentials
      result = client.authenticate!
      expect(result.token).to eq('new_token')
    end
  end
end
