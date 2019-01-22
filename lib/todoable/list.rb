module Todoable
  class List
    ENDPOINT = 'lists'.freeze

    class << self
      def all
        Todoable.http.get(ENDPOINT).body['lists'].map do |params|
          from_params params
        end
      end

      def from_params(params)
        list = new params['name'], params['id'], params['src']
      end

      def create(name)
        result = Todoable.http.post(ENDPOINT, list: { name: name })
        raise UnprocessableError, result.body if result.status == 422

        from_params result.body
      end

      def find(id)
        from_params Todoable.http.get([ENDPOINT, id].join('/')).body['list']
      end
    end

    attr_reader :name
    def initialize(name, id = nil, src = nil)
      @items = []
      @name = name
      @id = id
      @src = src
    end

    def name=(new_name)
      return if @name == new_name

      @name = new_name
      update
    end

    def items
      result = Todoable.http.get(@src)
      @name = result.body['name']
      Item.from_array result.body['items']
    end

    def add_item(name)
      Todoable.http.post([@src, 'items'].join('/'), item: { name: name }).body['item']
    end

    def destroy
      return if @src.nil?

      result = Todoable.http.delete(@src)
      raise NotFound if result.status == 404

      @id = nil
      @src = nil
    end

    private

    private_class_method :find

    def refresh
      # fetch list from server, updating name and items
    end

    def update
      # update to server
      refresh
    end
  end
end
