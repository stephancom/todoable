RSpec.describe Todoable do
  before do
    Todoable.configure do |config|
      config.username = 'todo@example.com'
      config.password = 'MyP455w0rd'
    end
  end
  it 'has a version number' do
    expect(Todoable::VERSION).not_to be nil
  end

  after do
    Todoable.config.reset!
  end
end
