require 'spec_helper'

RSpec.describe ImageServer::Url do
  describe '#from_hash' do
    let(:image_hash) { '3cfa2ba4236fc5984524adb9e0036cf6' }

    before do
      allow(ImageServer.configuration).to receive(:cdn_host) { 'example.com' }
      allow(ImageServer.configuration).to receive(:cdn_protocol) { 'http://' }
    end

    context 'image hash is present' do
      it 'returns the image url defaulting to jpg' do
        expect(ImageServer::Url.from_hash('p', image_hash, size: :x200)).to eq('http://example.com/p/3cf/a2b/a42/36fc5984524adb9e0036cf6/x200.jpg')
      end

      it 'allows to specify format' do
        expect(ImageServer::Url.from_hash('p', image_hash, size: :x300, format: :webp)).to end_with('/x300.webp')
      end

      it 'allows to specify protocol' do
        expect(ImageServer::Url.from_hash('p', image_hash, size: :x200, protocol: 'https://')).to start_with('https://')
      end

      it 'does not append format when requesting the original image' do
        expect(ImageServer::Url.from_hash('p', image_hash, size: :original, format: :jpeg)).to end_with('/original')
      end
    end

    context 'when domain is passed in' do
      it 'uses the domain' do
        expect(ImageServer::Url.from_hash('p', image_hash, domain: 'foo.example.com')).to start_with('http://foo.example.com')
      end
    end

    context 'when no domain is passed in' do
      before do
        allow(ImageServer.configuration).to receive(:sharded_cdn_host) { cdn_host }
        allow(ImageServer.configuration).to receive(:sharded_host_count) { 4 }
      end

      context 'when sharded domains are specified in configuration' do
        let(:cdn_host) { 'img-%d.example.com' }
        it 'defaults to using the sharded cdn domains' do
          expect(ImageServer::Url.from_hash('p', image_hash)).to start_with('http://img-3.example.com')
        end
      end

      context 'when no sharded domains are specified in configuration' do
        let(:cdn_host) { nil }
        it 'uses cdn_host' do
          expect(ImageServer::Url.from_hash('p', image_hash)).to start_with('http://example.com')
        end
      end
    end

    context 'image hash is not present' do
      it 'returns nil' do
        expect(ImageServer::Url.from_hash('p', nil, size: :x200)).to be_nil
      end
    end
  end
end