module Lita
  module Handlers
    class Todo < Handler
      config :server
      route(/^remind plz$/, :index, command: true, help: {"remind plz" => "List all todos."})
      route(/^pending plz$/, :pending, command: true, help: {"pending plz" => "List pending todos."})
      route(/^create\s(.+)$/, :create, command: true, help: {"create" => "create TODO"})
      route(/^today\s(.+)$/, :today, command: true, help: {"create" => "list today TODO"})
      route(/^done\s(.+)$/, :done, command: true, help: { "done TODO_ID" => "Marks todo with the specified number as done." })
      route(/^reopen\s(.+)$/, :reopen, command: true, help: { "done TODO_ID" => "Marks todo with the specified number as done." })
      route(/^\s(.+)$/, :done, command: true, help: { "done TODO_ID" => "Marks todo with the specified number as done." })

      def index(response)
        todos = parse get("#{config.server}/todos.json")
        if todos.any?
          todo = ["```"]
          todo << 'Your todos:'
          todos.map { |t| todo << "##{t['id']}: #{t['due']} - #{t['title']}" }
          todo << "```"
          todo = todo.join("\n")
          response.reply(todo)
        else
          response.reply('You have done all the todos! Good job!')
        end
      end

      def create(response)
        todo = response.match_data[1]
        todo = Hash[*todo.split('##').map { |a| a.gsub(/^([a-z]+):/,"todo[\\1]:").split(':') }.flatten]
        result = post "#{config.server}/todos.json", todo
        if result.code.to_i.success?
          response.reply("#{todo} was created")
        else
          #TODO
        end
      end

      def done(response)
        todo = response.math_data[1]
        result = post "#{config.server}/todo/#{todo}/done.json"
        if result.code.to_i.success?
          repsonse.reply("##{todo} was done")
        else
          #TODO
        end
      end

      def reopen(response)
        todo = response.math_data[1]
        result = post "#{config.server}/todo/#{todo}/reopen.json"
        if result.code.to_i.success?
          repsonse.reply("##{todo} was opened, AGAIN!!!")
        else
          #TODO
        end
      end

      def update_state(response)
        todo = response.match_data[1].split()
        result = put "#{config.server}/todos/#{todo[0]}/edit.json", { 'todo[status]' => todo[1] }
        if result.code.to_i.success?
          response.reply("Todo ##{todo[0]} was updated to #{todo[1]}")
        else
          #TODO
        end
      end

      private

      def get(url)
        Net::HTTP.get make_uri(url)
      end

      def post(url, data = {})
        Net::HTTP.post_form(make_uri(url), data)
      end

      def put(url, data = {})
        Net::HTTP.put(make_uri(url), data)
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
