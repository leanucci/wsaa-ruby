require 'spec_helper'
require 'openssl'
require 'base64'

RSpec.describe Wsaa::CmsSigner do
  let(:cert_path) { fixture_path('test_cert.pem') }
  let(:pkey_path) { fixture_path('test_key.pem') }

  subject(:signer) { described_class.new(cert_path: cert_path, pkey_path: pkey_path) }

  describe '#initialize' do
    it 'loads the certificate' do
      expect(signer.certificate).to be_a(OpenSSL::X509::Certificate)
    end

    it 'loads the private key' do
      expect(signer.private_key).to be_a(OpenSSL::PKey::RSA)
    end

    context 'with invalid certificate' do
      let(:cert_path) { fixture_path('test_key.pem') }

      it 'raises SigningError' do
        expect { signer }.to raise_error(Wsaa::SigningError, /Invalid certificate/)
      end
    end

    context 'with invalid private key' do
      let(:pkey_path) { fixture_path('test_cert.pem') }

      it 'raises SigningError' do
        expect { signer }.to raise_error(Wsaa::SigningError, /Invalid private key/)
      end
    end

    context 'with non-existent certificate file' do
      let(:cert_path) { '/nonexistent/cert.pem' }

      it 'raises SigningError' do
        expect { signer }.to raise_error(Wsaa::SigningError, /Certificate file not found/)
      end
    end

    context 'with non-existent private key file' do
      let(:pkey_path) { '/nonexistent/key.pem' }

      it 'raises SigningError' do
        expect { signer }.to raise_error(Wsaa::SigningError, /Private key file not found/)
      end
    end
  end

  describe '#sign' do
    let(:data) { '<?xml version="1.0"?><test>data</test>' }

    it 'returns a base64-encoded string' do
      result = signer.sign(data)
      expect { Base64.strict_decode64(result) }.not_to raise_error
    end

    it 'produces valid PKCS7 structure' do
      result = signer.sign(data)
      der = Base64.strict_decode64(result)
      pkcs7 = OpenSSL::PKCS7.new(der)
      expect(pkcs7).to be_a(OpenSSL::PKCS7)
    end

    it 'produces a signed-data PKCS7 type' do
      result = signer.sign(data)
      der = Base64.strict_decode64(result)
      pkcs7 = OpenSSL::PKCS7.new(der)

      expect(pkcs7.type).to eq(:signed)
    end

    it 'includes the signer certificate' do
      result = signer.sign(data)
      der = Base64.strict_decode64(result)
      pkcs7 = OpenSSL::PKCS7.new(der)

      expect(pkcs7.certificates.size).to eq(1)
      expect(pkcs7.certificates.first.subject.to_s).to eq(signer.certificate.subject.to_s)
    end
  end
end
