require 'spec_helper'
require 'image_server/active_record'
require 'pry'

RSpec.describe ImageServer::ActiveRecord do
  class SampleClass
    extend ImageServer::ActiveRecord

    attr_accessor :image_hash, :avatar_hash

    image_server :image, {
      namespace: 'p',
      versions: {full_size: 'full_size', x262: 'x262-q90', w620: 'w620-q90'},
      processing_formats: [:jpg],
    }

    image_server :avatar, {
      namespace: 'a',
      default_size: 'x200-90',
      versions: {full_size: 'full_size', x200: 'x200-90'},
      processing: {formats: [:jpg], versions: [:full_size]}
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

    def avatar_hash
      'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
    end
  end

  let(:test_class) { SampleClass }
  let(:test_object) { test_class.new }

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
      stub_request(:post, 'http://127.0.0.1:7000/p?outputs=full_size.jpg,w620-q90.jpg,x262-q90.jpg&source=http://example.com/image.jpg').
        with(:body => '{}',
          :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}).
        to_return(:status => 200, :body => response_body, :headers => {})

      expect {
        test_object.remote_image_url = 'http://example.com/image.jpg'
      }.to change(test_object, :image_hash).from(nil).to(img_hash)
    end

    context 'processing versions is defined' do
      it 'uploads an image and processes only defined versions' do
        stub_request(:post, 'http://127.0.0.1:7000/a?outputs=full_size.jpg&source=http://example.com/image.jpg').
          with(:body => '{}',
            :headers => {'Accept' => 'application/json', 'Content-Type' => 'application/json'}).
          to_return(:status => 200, :body => response_body, :headers => {})

        expect {
          test_object.remote_avatar_url = 'http://example.com/image.jpg'
        }.to change(test_object, :avatar_hash).from(nil).to(img_hash)
      end
    end
  end

  describe '#[column_name]_url' do
    before do
      test_object.avatar_hash = 'bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb'
    end

    it 'returns the default size' do
      expect(test_object.avatar_url).to eq('/a/bbb/bbb/bbb/bbbbbbbbbbbbbbbbbbbbbbb/x200-90.jpg')
    end

    it 'allows to get custom size' do
      expect(test_object.avatar_url(size: 'full_size')).to eq('/a/bbb/bbb/bbb/bbbbbbbbbbbbbbbbbbbbbbb/full_size.jpg')
    end
  end
end