require 'spec_helper'
require 'tmpdir'

RSpec.describe Wsaa::CredentialStore do
  let(:cache_dir) { Dir.mktmpdir }
  let(:service) { 'wsfe' }

  subject(:store) { described_class.new(cache_dir: cache_dir, service: service) }

  after { FileUtils.remove_entry(cache_dir) }

  describe '#cache_file_path' do
    it 'uses date-based filename' do
      date_str = Time.now.strftime('%d_%m_%Y')
      expect(store.cache_file_path).to include("wsaa_wsfe_#{date_str}.yml")
    end

    it 'uses the configured cache directory' do
      expect(store.cache_file_path).to start_with(cache_dir)
    end

    it 'includes the service name' do
      expect(store.cache_file_path).to include('wsfe')
    end
  end

  describe '#write' do
    let(:expiration_time) { Time.now + 3600 }
    let(:credentials) do
      Wsaa::Credentials.new(
        token: 'test_token',
        sign: 'test_sign',
        expiration_time: expiration_time
      )
    end

    it 'writes credentials to YAML file' do
      store.write(credentials)
      expect(File.exist?(store.cache_file_path)).to be true
    end

    it 'returns the credentials' do
      expect(store.write(credentials)).to eq(credentials)
    end

    it 'writes valid YAML' do
      store.write(credentials)
      data = YAML.load_file(store.cache_file_path)
      expect(data['token']).to eq('test_token')
      expect(data['sign']).to eq('test_sign')
    end
  end

  describe '#read' do
    context 'when cache file does not exist' do
      it 'returns nil' do
        expect(store.read).to be_nil
      end
    end

    context 'when cache file exists with valid credentials' do
      let(:expiration_time) { Time.now + 3600 }

      before do
        credentials = Wsaa::Credentials.new(
          token: 'cached_token',
          sign: 'cached_sign',
          expiration_time: expiration_time
        )
        store.write(credentials)
      end

      it 'returns Credentials object' do
        expect(store.read).to be_a(Wsaa::Credentials)
      end

      it 'returns credentials with correct token' do
        expect(store.read.token).to eq('cached_token')
      end

      it 'returns credentials with correct sign' do
        expect(store.read.sign).to eq('cached_sign')
      end
    end

    context 'when cache file contains expired credentials' do
      before do
        credentials = Wsaa::Credentials.new(
          token: 'expired_token',
          sign: 'expired_sign',
          expiration_time: Time.now - 3600
        )
        store.write(credentials)
      end

      it 'returns nil' do
        expect(store.read).to be_nil
      end
    end

    context 'when cache file is corrupted' do
      before do
        File.write(store.cache_file_path, 'invalid yaml: [')
      end

      it 'returns nil' do
        expect(store.read).to be_nil
      end
    end
  end

  describe '#clear' do
    before do
      credentials = Wsaa::Credentials.new(
        token: 'token',
        sign: 'sign',
        expiration_time: Time.now + 3600
      )
      store.write(credentials)
    end

    it 'deletes the cache file' do
      expect(File.exist?(store.cache_file_path)).to be true
      store.clear
      expect(File.exist?(store.cache_file_path)).to be false
    end

    it 'does not raise when file does not exist' do
      store.clear
      expect { store.clear }.not_to raise_error
    end
  end
end
