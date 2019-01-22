module Todoable
  class List
    ENDPOINT = 'lists'

    class << self
      def all
        Todoable.http.get(ENDPOINT).body['lists'].map do |params|
          new(params['name'], params['id'], params['src'])
        end
      end

      def create(name)
        raise Todoable::Error if name.nil? || name.empty?

        Todoable.http.post(ENDPOINT, list: { name: name })
      end

      def find(id)
        Todoable.http.get([ENDPOINT,id].join('/')).body['list']
      end
    end

    attr_reader :name
    attr_accessor :items
    def initialize(name, id, src)
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

    def destroy
      Todoable.http.delete(@src)
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
