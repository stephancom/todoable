require 'singleton'

module Todoable
  # Singleton representing the Todoable config.
  #
  # @since v0.1.0
  class Config
    include Singleton

    DEFAULT_HOST = 'http://todoable.teachable.tech/api/'.freeze

    # @return [String] the username for API connection
    attr_accessor :username

    # @return [String] the password for API access
    attr_accessor :password

    # @return [String] the host for Todoable API access
    attr_accessor :host

    # initializes the config object
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

    # Reset configuration. Primarily for debugging
    # @api private
    def reset!
      @password = nil
      @username = nil
      initialize
    end
  end
end
