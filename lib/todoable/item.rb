module Todoable
  # Represents a Todoable list item
  #
  # @since v0.1.0
  class Item
    class << self
      # Creates item object from params
      #
      # @param params [Hash]
      # @return [Item]
      def from_params(params)
        finished_at = params['finished_at']
        finished_at = Time.parse(finished_at) unless finished_at.nil?
        new(params['name'], finished_at, params['id'], params['src'])
      end
    end

    # @return [String] item name
    attr_reader :name

    # Initialize new item
    #
    # @param name [String] name of list
    # @param finished_at [Time] time when finished, or nil if not finished
    # @param id [String] GUID of item
    # @param src [String] canonical full URL of item
    def initialize(name, finished_at, id, src)
      @name = name
      @finished_at = finished_at
      @id = id
      @src = src
    end

    # Item finished state
    #
    # @return [Boolean]
    def finished?
      !@finished_at.nil? && @finished_at < Time.now
    end

    # Mark item finished
    #
    # @see http://todoable.teachable.tech/#put-lists-id-items-id-finish
    def finish!
      response = Todoable.http.put([@src, 'finish'].join('/'))
      raise Error, response.body unless response.status == Client::HTTP_OK

      @finished_at = Time.now
    end

    # Destroy item
    # @see http://todoable.teachable.tech/#delete-lists-id-items-id
    def destroy
      return if @src.nil?

      response = Todoable.http.delete(@src)
      raise Error, response.body unless response.status == Client::HTTP_NO_CONTENT

      @id = nil
      @src = nil
    end
  end
end
