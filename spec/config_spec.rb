require 'spec_helper'

RSpec.describe Todoable::Config do
  let(:config) { described_class.instance }

  describe '#new' do
    it 'does not set the username' do
      expect(config.username).to be_nil
    end

    it 'does not set the password' do
      expect(config.password).to be_nil
    end

    it 'sets the default host' do
      expect(config.host).to eq('http://todoable.teachable.tech/api/')
    end
  end

  describe '#valid?' do
    it 'is false when username is blank' do
      config.username = ''
      config.password = '$0meP455w0rd'
      expect(config).not_to be_valid
    end
    it 'is false when password is blank' do
      config.username = 'someone@example.com'
      config.password = ''
      expect(config).not_to be_valid
    end
    it 'is true when username/password filled in' do
      config.username = 'someone@example.com'
      config.password = '$0meP455w0rd'
      expect(config).to be_valid
    end
  end
  
  after do
    Todoable.config.reset!
  end
end
