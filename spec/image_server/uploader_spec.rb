require 'spec_helper'
require 'image_server/uploader'

RSpec.describe ImageServer::Uploader do
  class ImageProperty
    def initialize(attributes = {})
    end
  end

  before do
    allow(ImageProperty).to receive(:where).and_return(ImageProperty)
    allow(ImageProperty).to receive(:first)
    allow_any_instance_of(ImageProperty).to receive(:assign_attributes)
    allow_any_instance_of(ImageProperty).to receive(:save!)
  end

  describe '.upload' do
    context 'when a string url is passed as source' do
      before do
        stub_request(:post, 'http://my_image.png').
          to_return(status: 200, body: File.read('spec/fixtures/images/one.png'))

        stub_request(:post, 'http://127.0.0.1:7000/img?outputs=full_size&source=http://my_image.png').
         to_return(status: 200, body: "{}")
      end

      it 'uploads downloads the image and the it upoloads it' do
        uploader = ImageServer::Uploader.new('img', 'http://my_image.png', 'full_size')

        expect_any_instance_of(ImageProperty).to receive(:save!)

        uploader.upload

        expect(a_request(:post, 'http://127.0.0.1:7000/img?outputs=full_size&source=http://my_image.png')).
          to have_been_made
      end
    end

    context 'when a file is passed as source' do
      before do
        stub_request(:post, 'http://127.0.0.1:7000/img?outputs=full_size').
         to_return(status: 200, body: "{}")
      end

      it 'uploads the file' do
        file = Tempfile.new('foo')
        uploader = ImageServer::Uploader.new('img', file, 'full_size')

        expect_any_instance_of(ImageProperty).to_not receive(:save!)

        uploader.upload

        expect(a_request(:post, 'http://127.0.0.1:7000/img?outputs=full_size')).
          to have_been_made
      end
    end
  end
end
