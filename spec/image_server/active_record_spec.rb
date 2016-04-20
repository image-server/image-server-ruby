require 'spec_helper'
require 'image_server/active_record'
require 'pry'

RSpec.describe ImageServer::ActiveRecord do
  class SampleClass < Struct.new(:image_hash)
    extend ImageServer::ActiveRecord

    image_server :image, {
      namespace: 'p',
      versions: {full_size: 'full_size', x262: 'x262-q90', w620: 'w620-q90'},
      processing_formats: [:jpg],
    }
  end

  class ImageProperty
    def initialize(attributes)
    end

    def assign_attributes(attributes)
    end

    def save!
      true
    end

    def image_hash
      '6e0072682e66287b662827da75b244a3'
    end
  end

  let(:test_class) { SampleClass }

  before do
    allow(ImageProperty).to receive(:where) { double(first: nil, where: double(first: nil)) }
  end

  describe '#remote_[column_name]_url=' do
    let(:img_hash) { '6e0072682e66287b662827da75b244a3' }
    let(:response_body) { {
      "hash": img_hash,
      "height": 600,
      "width": 800,
      "content_type": "image/jpeg"
    }.to_json }

    it 'uploads an image' do
      stub_request(:post, "http://127.0.0.1:7000/p?outputs=full_size.jpg,w620-q90.jpg,x262-q90.jpg&source=http://example.com/image.jpg").
        with(:body => "{}",
          :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}).
        to_return(:status => 200, :body => response_body, :headers => {})

      object = test_class.new
      expect {
        object.remote_image_url = 'http://example.com/image.jpg'
      }.to change(object, :image_hash).from(nil).to(img_hash)
    end
  end
end