require 'faraday'
require 'faraday_middleware'
require 'faraday_middleware/parse_oj'
require 'singleton'

module Todoable
  # Represents the Todoable http client
  #
  # @since v0.1.0
  class Client
    include Singleton

    # @see https://http.cat/200
    HTTP_OK = 200
    # @see https://http.cat/201
    HTTP_CREATED = 201
    # @see https://http.cat/204
    HTTP_NO_CONTENT = 204
    # @see https://http.cat/401
    HTTP_UNAUTHORIZED = 401
    # @see https://http.cat/422
    HTTP_UNPROCESSABLE_ENTITY = 422

    # starts up a new faraday connection
    def initialize
      refresh
    end

    # refreshes the connection if the token has expired
    #
    # @return [Faraday::Connection]
    def conn
      refresh if @conn.nil? || !token_valid?
      @conn
    end

    def conn2
      refresh if @conn.nil? || !token_valid?
      Faraday.new(url: Todoable.config.host) do |f|
        f.request  :url_encoded
        f.headers['Accept'] = 'application/json'
        f.headers['Content-Type'] = 'application/json'
        f.token_auth(@token)
        f.adapter Faraday.default_adapter
      end
    end

    def conn3
      refresh if @conn.nil? || !token_valid?
      Faraday.new(url: Todoable.config.host) do |f|
        f.response :oj
        f.headers['Accept'] = 'application/json'
        f.headers['Content-Type'] = 'application/json'
        f.token_auth(@token)
        f.adapter Faraday.default_adapter
      end
    end

    private

    # Common settings for Faraday
    #
    # @api private
    def json_headers(faraday)
      faraday.request :json
      faraday.response :oj
      faraday.headers['Accept'] = 'application/json'
      faraday.headers['Content-Type'] = 'application/json'
    end

    def refresh
      authenticate unless token_valid?
      @conn = Faraday.new(url: Todoable.config.host) do |f|
        json_headers(f)
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
        json_headers(f)
        f.basic_auth(Todoable.config.username, Todoable.config.password)
        f.adapter Faraday.default_adapter
      end
      resp = authconn.post('authenticate')
      @token = resp.body['token']
      @token_expires_at = Time.parse(resp.body['expires_at'])
    end
  end
end
