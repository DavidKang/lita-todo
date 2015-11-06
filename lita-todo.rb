module Lita
  module Handlers
    class Todo < Handler
      route(/^\/list$/, :index, command: true, help: {"/list" => "List all todos."})

      def index(response)
        response.reply('You have done all the todos! Good job!')
      end


      private

      def get(url)
        Net::HTTP.get make_uri(url)
      end

      def parse(obj)
        MultiJson.load(obj)
      end

      def make_uri(url)
        URI(url)
      end
    end
    Lita.register_handler(Todo)
  end
end

