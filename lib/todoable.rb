require 'todoable/client'
require 'todoable/config'
require 'todoable/item'
require 'todoable/list'
require 'todoable/version'

# the root of the Todoable gem
module Todoable
  # general error
  class Error < StandardError; end
  # error corrsponding to http status code 422
  class UnprocessableError < StandardError; end

  class << self
    # yields block to context of config object
    def configure
      yield(Todoable::Config.instance)
    end

    # @return [Todoable::Config]
    def config
      Todoable::Config.instance
    end

    # @return [Faraday::Connection]
    def http
      Todoable::Client.instance.conn
    end
  end
end
