require 'spec_helper'

describe Image::Server::Ruby do
  it 'has a version number' do
    expect(Image::Server::Ruby::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end
end
