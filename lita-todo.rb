module Lita
  module Handlers
    class Todo < Handler
      config :server
      route(/^remind plz$/, :index, command: true, help: {"remind plz" => "List all todos."})
      route(/^create\s(.+)$/, :create, command: true, help: {"create" => "create TODO"})

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

      def create(response)
        todo = response.match_data[1]
        result = post "#{config.server}/todos.json", {'todo[title]' => todo, 'todo[due]' => Date.today }
        if result.code.to_i.success?
          response.reply("#{todo} was created")
        else
          response.reply()
        end
      end

      private

      def get(url)
        Net::HTTP.get make_uri(url)
      end

      def post(url, data = {})
        Net::HTTP.post_form(make_uri(url), data)
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

class Numeric
  def success?
    self > 199 && self < 300
  end
end
