module Todoable
  # Represents a Todoable list
  #
  # @see http://todoable.teachable.tech
  #
  # @since v0.1.0
  class List
    # base endpoint for listing/creating lists
    ENDPOINT = 'lists'.freeze

    class << self
      # Retrieve all lists
      #
      # @see http://todoable.teachable.tech/#get-lists
      #
      # @return [Array<List>] the lists
      def all
        response = Todoable.http.get(ENDPOINT)
        raise Error, response.body unless response.status == Client::HTTP_OK

        response.body['lists'].map do |params|
          from_params params
        end
      end

      # Create list
      #
      # @see http://todoable.teachable.tech/#post-lists
      #
      # @param name [String]
      # @return [List]
      def create(name)
        response = Todoable.http.post(ENDPOINT, list: { name: name })
        raise UnprocessableError, response.body if response.status == Client::HTTP_UNPROCESSABLE_ENTITY
        raise Error, response.body unless response.status == Client::HTTP_CREATED

        from_params response.body
      end

      # Creates list object from params
      #
      # @param params [Hash]
      # @return [List]
      def from_params(params)
        new params['name'], params['id'], params['src']
      end
    end

    # @return [String] list name
    attr_reader :name

    # Initialize new list
    #
    # @param name [String] name of list
    # @param id [String] GUID of list
    # @param src [String] canonical full URL of list
    def initialize(name, id, src)
      @name = name
      @id = id
      @src = src
    end

    # Change list name, and update to server
    #
    # @see http://todoable.teachable.tech/#patch-lists-id
    #
    # @param name [String] new name for list
    def name=(name)
      return if @name == new_name

      @name = new_name
      Todoable.http.patch(@url, list: { name: name })
      raise UnprocessableError, response.body if response.status == Client::HTTP_UNPROCESSABLE_ENTITY
      raise Error, response.body unless response.status == Client::HTTP_NO_CONTENT
    end

    # Retrieve list items.  May update name as a side effect.
    #
    # @see http://todoable.teachable.tech/#post-lists
    #
    # @return [Array<Item>] list of items
    def items
      response = Todoable.http.get(@src)
      raise Error, response.body unless response.status == Client::HTTP_OK

      @name = response.body['name']
      response.body['items'].map do |params|
        Item.from_params params
      end
    end

    # Add new item to list
    #
    # @see http://todoable.teachable.tech/#post-lists-id-items
    #
    # @param name [String] name of item
    # @return [Item] the newly created item
    def add_item(name)
      Item.from_params Todoable.http.post([@src, 'items'].join('/'), item: { name: name }).body['item']
      raise UnprocessableError, response.body if response.status == Client::HTTP_UNPROCESSABLE_ENTITY
      raise Error, response.body unless response.status == Client::HTTP_CREATED
    end

    # Destroy list
    #
    # @see http://todoable.teachable.tech/#delete-lists-id
    def destroy
      response = Todoable.http.delete(@src)
      raise Error, response.body unless response.status == Client::HTTP_NO_CONTENT

      # prevent trying to delete it again
      @id = nil
      @src = nil
    end
  end
end
