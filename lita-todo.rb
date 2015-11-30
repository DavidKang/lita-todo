module Lita
  module Handlers
    class Todo < Handler
      config :server
      route(/^remind plz$/, :index, command: true, help: {"remind plz" => "List all todos."})
      route(/^remind done plz$/, :remind_done, command: true, help: {"pending plz" => "List pending todos."})
      route(/^create\s(.+)$/, :create, command: true, help: {"create" => "create TODO"})
      route(/^(title:\s.+)$/, :create, command: true, help: {"create" => "create TODO"})
      route(/^today\s(.+)$/, :today, command: true, help: {"today" => "list today TODO"})
      route(/^done\s(\d+)$/, :done, command: true, help: { "done TODO_ID" => "Marks todo with the specified number as done." })
      route(/^reopen\s(\d+)$/, :reopen, command: true, help: { "reopen TODO_ID" => "Marks todo with the specified number as pending." })
      route(/^#(\d+)$/, :done, command: true, help: { "done TODO_ID" => "Marks todo with the specified number as done." })

      def index(response)
        todos = parse get("#{config.server}/todos.json")
        if todos.any?
          todo = ["```"]
          todo << 'Your pending todos:'
          todos.map { |t| todo << "##{t['id']}: #{t['due']} - #{t['project']} - #{t['title']}" }
          todo << "```"
          todo = todo.join("\n")
          response.reply(todo)
        else
          response.reply('You have done all the todos! Good job!')
        end
      end

      def remind_done(response)
        todos = parse get("#{config.server}/done_todos.json")
        if todos.any?
          todo = ["```"]
          todo << 'Your finished todos:'
          todos.map { |t| todo << "##{t['id']}: #{t['due']} - #{t['project']} - #{t['title']}" }
          todo << "```"
          todo = todo.join("\n")
          response.reply(todo)
        else
          response.reply("You don't have finished todos! :(")
        end
      end

      def create(response)
        require 'yaml'
        todo = "{#{response.match_data[1]}}"
        STDERR.puts "todo: #{todo}"
        todo = YAML.load(todo)
        # TODO Mejorar esto (Hay que poner las keys como todo[:nombre])
        new_todo = {}
        todo.each {|k,v| new_todo["todo[#{k}]"] = v}
        result = post "#{config.server}/todos.json", new_todo
        if result.code.to_i.success?
          response.reply("#{todo} was created")
        else
          #TODO
        end
      end

      def done(response)
        todo = response.match_data[1]
        result = post "#{config.server}/todo/#{todo}/done.json"
        if result.code.to_i.success?
          response.reply("##{todo} was done")
        else
          #TODO
        end
      end

      def reopen(response)
        todo = response.match_data[1]
        result = post "#{config.server}/todo/#{todo}/reopen.json"
        if result.code.to_i.success?
          response.reply("##{todo} was opened, AGAIN!!!")
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
