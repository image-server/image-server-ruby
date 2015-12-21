require 'spec_helper'

RSpec.describe ImageServer::Adapters::Http do

  let(:outputs) { 'full_size.jpg,x110-q90.jpg' }
  let(:uploader) { ImageServer::Adapters::Http.new('p', 'http://example.com/image.url?a=1&b=2', outputs) }
  let(:response) { {hash: 'IMAGEHASH', width: '20', height: '40'} }
  let(:response_code) { 200 }

  before do
    stub_request(:post, "http://#{ImageServer.configuration.upload_host}/p?outputs=full_size.jpg,x110-q90.jpg&source=http://example.com/image.url?a=1%26b=2").
      to_return(status: response_code, body: response.to_json, headers: {})
  end

  describe '#upload' do

    context 'the url does not contain scheme' do
      let(:uploader) { ImageServer::Adapters::Http.new('p', '//example.com/image.url?a=1&b=2', outputs) }

      it 'requests the image with http' do
        uploader.upload
      end
    end

    context 'the source is a file' do
      before do
        stub_request(:post, 'http://127.0.0.1:7000/p?outputs=full_size.jpg,x110-q90.jpg').
          with(
            body: "\x89PNG\r\n\u001A\n\u0000\u0000\u0000\rIHDR\u0000\u0000\u0000\u0001\u0000\u0000\u0000\u0001\u0001\u0003\u0000\u0000\u0000%\xDBV\xCA\u0000\u0000\u0000\u0004gAMA\u0000\u0000\xB1\x8F\v\xFCa\u0005\u0000\u0000\u0000 cHRM\u0000\u0000z&\u0000\u0000\x80\x84\u0000\u0000\xFA\u0000\u0000\u0000\x80\xE8\u0000\u0000u0\u0000\u0000\xEA`\u0000\u0000:\x98\u0000\u0000\u0017p\x9C\xBAQ<\u0000\u0000\u0000\u0006PLTE\xFF\u0000\xFF\xFF\xFF\xFF\x9F\u00182\xE0\u0000\u0000\u0000\u0001bKGD\u0001\xFF\u0002-\xDE\u0000\u0000\u0000\atIME\a\xDF\f\u0015\u000F\u0015,\x83\xBA\x83<\u0000\u0000\u0000\nIDAT\b\xD7c`\u0000\u0000\u0000\u0002\u0000\u0001\xE2!\xBC3\u0000\u0000\u0000%tEXtdate:create\u00002015-12-21T15:21:44-08:00\u000E\u0011\xF5o\u0000\u0000\u0000%tEXtdate:modify\u00002015-12-21T15:21:44-08:00\u007FLM\xD3\u0000\u0000\u0000\u0000IEND\xAEB`\x82"
          ).to_return(status: response_code, body: response.to_json, headers: {})
      end

      let(:image_path) { 'spec/fixtures/images/one.png' }
      let(:image) { File.open(File.join(image_path)) }
      let(:uploader) { ImageServer::Adapters::Http.new('p', image, outputs) }

      it 'uploads the image and generates an image hash' do
        uploader.upload
        expect(uploader.image_hash).to eq('IMAGEHASH')
      end
    end

  end

  describe 'hash' do
    it 'returns the hash included in the response' do
      uploader.upload
      expect(uploader.image_hash).to eq('IMAGEHASH')
    end
  end

  describe 'width' do
    it 'returns the width included in the response' do
      uploader.upload
      expect(uploader.width).to eq(20)
    end
  end

  describe 'height' do
    it 'returns the height included in the response' do
      uploader.upload
      expect(uploader.height).to eq(40)
    end
  end

  describe 'error states' do
    context 'when original image is not found' do
      let(:response_code) { 404 }
      let(:response) { {error: 'Unable to download image: http://example.com/does-not-exist.jpg, status code: 404'} }

      it 'raises a SourceNotFound error' do
        expect {
          uploader.upload
        }.to raise_error(ImageServer::SourceNotFound)
      end
    end

    context 'the server is unable to process the request' do
      let(:response_code) { 503 }
      let(:response) { nil }

      it 'raises a ImageServerUnavailable error' do
        expect {
          uploader.upload
        }.to raise_error(ImageServer::ImageServerUnavailable)
      end
    end

    context 'the server responds with other errors' do
      let(:response_code) { 404 }
      let(:response) { {error: 'Get http://example.com:7000/p/729/15f/918/bb17228b26031b802079091/original: dial tcp 10.100.16.202:7000: connection refused'} }

      it 'raises a UploadError error' do
        expect {
          uploader.upload
        }.to raise_error(ImageServer::PermanentFailure)
      end
    end
  end
end