require 'spec_helper'

RSpec.describe ImageServer::Configuration do
  describe '#port' do
    let(:configuration) { described_class.new }

    context 'upload host contains a port' do
      it 'extracts port' do
        configuration.upload_host = 'example.com:7000'
        expect(configuration.port).to eq(7000)
      end
    end

    context 'upload host does not contain a port' do
      it 'default to port 80' do
        configuration.upload_host = 'example.com'
        expect(configuration.port).to eq(80)
      end
    end

    it 'returns nil when there is no upload host' do
      configuration.upload_host = nil
      expect(configuration.port).to be_nil
    end
  end
end