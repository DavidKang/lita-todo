module Lita
  module Handlers
    class Todo < Handler
      config :server
      route(/^remind plz$/, :index, command: true, help: {"/list" => "List all todos."})

      def index(response)
        todos = parse get("#{config.server}/todos.json")
        if todos.any?
          response.reply('Your todos:')
          todos.each do |todo|
            # resonse.reply("#{todo['due']} - #{todo['title']}")
            response.reply("# #{todo['id']}: #{todo['due']} - #{todo['title']}")
          end
        else
          response.reply('You have done all the todos! Good job!')
        end
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

