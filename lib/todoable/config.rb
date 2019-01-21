require 'singleton'

module Todoable
  # Represents the Todoable config.
  #
  # @api private
  # @since v0.0.1
  class Config
    include Singleton

    DEFAULT_HOST = 'http://todoable.teachable.tech/api/'.freeze

    # @return [String] the username for API connection
    # @api public
    attr_accessor :username

    # @return [String] the password for API access
    # @api public
    attr_accessor :password

    # @return [String] the host for Todoable API access
    # @api private
    attr_accessor :host

    # @param [Hash{Symbol=>Object}] user_config the hash to be used to build the config
    def initialize
      self.host = DEFAULT_HOST
    end

    # @return [Boolean] true if the config meets the requirements, false otherwise
    def valid?
      !@password&.empty? && !@username&.empty? && !@host.empty?
    end

    # The full URL to the base Todoable. Based on the +:host+ option.
    # @return [URI] the base address
    def base_url
      @base_url ||= URI.join(host, 'api')
    end

    def reset!
      @password = nil
      @username = nil
      initialize
    end
  end
end
