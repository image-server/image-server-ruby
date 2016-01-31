require 'spec_helper'
require 'image_server/path'

RSpec.describe ImageServer::Path do
  let(:image_hash) { '3cfa2ba4236fc5984524adb9e0036cf6' }

  describe '.directory_path' do
    it 'incluces the namespace and the partitioned hash' do
      path = described_class.directory_path('p', image_hash)
      expect(path).to eq('p/3cf/a2b/a42/36fc5984524adb9e0036cf6')
    end
  end
end