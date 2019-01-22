require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/parse_oj'
require 'singleton'

module Todoable
  # Represents the Todoable http client
  #
  # @api private
  # @since v0.0.1
  class Client
    include Singleton

    def initialize
      refresh
    end

    def conn
      refresh if @conn.nil? || !token_valid?
      @conn
    end

    private

    def refresh
      authenticate unless token_valid?
      @conn = Faraday.new(url: Todoable.config.host) do |f|
        f.request :json
        f.response :oj
        f.headers['Accept'] = 'application/json'
        f.headers['Content-Type'] = 'application/json'
        f.basic_auth(Todoable.config.username, Todoable.config.password)
        f.token_auth(@token)
        f.adapter Faraday.default_adapter
      end
    end

    def token_valid?
      !@token.nil? && Time.now < @token_expires_at
    end

    def authenticate
      @conn = nil # eliminate existing connection
      authconn = Faraday.new(url: Todoable.config.host) do |f|
        f.response :oj
        f.headers['Accept'] = 'application/json'
        f.headers['Content-Type'] = 'application/json'
        f.basic_auth(Todoable.config.username, Todoable.config.password)
        f.adapter Faraday.default_adapter
      end
      resp = authconn.post('authenticate')
      @token = resp.body['token']
      @token_expires_at = Time.parse(resp.body['expires_at'])
    end
  end
end
