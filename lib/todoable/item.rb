module Todoable
  class Item
    class << self
      def from_params(params)
        finished_at = params['finished_at']
        finished_at = Time.parse(finished_at) unless finished_at.nil?
        new(params['name'], finished_at, params['id'], params['src'])
      end

      def from_array(param_array)
        return if param_array.nil?

        param_array.map { |params|
          from_params(params)
        }
      end
    end

    def initialize(name, finished_at, id, src)
      @name = name
      @finished_at = finished_at
      @id = id
      @src = src
    end

    def finished?
      !@finished_at.nil? && @finished_at < Time.now
    end

    def finish!
      result = Todoable.http.put([@src, 'finish'].join('/'))
      @finished_at = Time.now if result.status == 201
      # TODO: catch errors
    end

    def destroy
      return if @src.nil?

      result = Todoable.http.delete(@src)
      raise NotFound if result.status == 404

      @id = nil
      @src = nil
    end
  end
end
