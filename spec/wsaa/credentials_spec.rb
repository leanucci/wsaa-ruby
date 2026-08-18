require 'spec_helper'

RSpec.describe Wsaa::Credentials do
  let(:token) { 'test_token_value' }
  let(:sign) { 'test_sign_value' }
  let(:expiration_time) { Time.now + 3600 }

  subject(:credentials) do
    described_class.new(token: token, sign: sign, expiration_time: expiration_time)
  end

  describe '#initialize' do
    it 'stores the token' do
      expect(credentials.token).to eq(token)
    end

    it 'stores the sign' do
      expect(credentials.sign).to eq(sign)
    end

    it 'stores the expiration_time' do
      expect(credentials.expiration_time).to eq(expiration_time)
    end

    it 'freezes the token' do
      expect(credentials.token).to be_frozen
    end

    it 'freezes the sign' do
      expect(credentials.sign).to be_frozen
    end

    it 'freezes the object' do
      expect(credentials).to be_frozen
    end
  end

  describe '#expired?' do
    context 'when expiration_time is in the future' do
      let(:expiration_time) { Time.now + 3600 }

      it 'returns false' do
        expect(credentials.expired?).to be false
      end
    end

    context 'when expiration_time is in the past' do
      let(:expiration_time) { Time.now - 3600 }

      it 'returns true' do
        expect(credentials.expired?).to be true
      end
    end
  end

  describe '#valid?' do
    context 'with valid non-expired credentials' do
      it 'returns true' do
        expect(credentials.valid?).to be true
      end
    end

    context 'with expired credentials' do
      let(:expiration_time) { Time.now - 3600 }

      it 'returns false' do
        expect(credentials.valid?).to be false
      end
    end

    context 'with nil token' do
      let(:token) { nil }

      it 'returns false' do
        expect(credentials.valid?).to be false
      end
    end

    context 'with nil sign' do
      let(:sign) { nil }

      it 'returns false' do
        expect(credentials.valid?).to be false
      end
    end
  end

  describe '#to_h' do
    it 'returns a hash with token' do
      expect(credentials.to_h[:token]).to eq(token)
    end

    it 'returns a hash with sign' do
      expect(credentials.to_h[:sign]).to eq(sign)
    end

    it 'returns expiration_time as ISO8601 string' do
      expect(credentials.to_h[:expiration_time]).to eq(expiration_time.iso8601)
    end
  end
end
