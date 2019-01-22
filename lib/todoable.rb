require 'todoable/client'
require 'todoable/config'
require 'todoable/list'
require 'todoable/version'

# the root of the Todoable gem
module Todoable
  class Error < StandardError; end

  class << self
    def configure
      yield(Todoable::Config.instance)
    end

    def config
      Todoable::Config.instance
    end

    def http
      Todoable::Client.instance.conn
    end
  end
end
