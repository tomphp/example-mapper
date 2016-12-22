require 'faye/websocket'
require 'json'
require 'mysql2'
require 'securerandom'

module ExampleMapper
  module Middlewares
    class Backend
      KEEPALIVE_TIME = 15

      def initialize(app)
        @app     = app
        @clients = {}
        story_id = SecureRandom.uuid
        @state = {
          cards: {
            story_id => {
              id: story_id,
              text: 'As a ??? I want to ???',
              state: :saved
            }
          },
          story_card: story_id,
          rules: [
          ],
          questions: [
          ]
        }

        @fetch_story_stmt = client.prepare('SELECT * FROM stories WHERE story_id = ?')
        @fetch_cards_stmt = client.prepare('SELECT * FROM cards WHERE story_id = ?')
        @fetch_questions_stmt = client.prepare('SELECT * FROM questions WHERE story_id = ? ORDER BY created ASC')
        @fetch_rules_stmt = client.prepare('SELECT * FROM rules WHERE story_id = ? ORDER BY created ASC')
        @fetch_examples_stmt = client.prepare('SELECT * FROM examples WHERE rule_card_id = ? ORDER BY created ASC')
        @update_card_query_stmt = client.prepare('UPDATE cards SET text = ? WHERE card_id = ?')
        @add_card_stmt = client.prepare('INSERT INTO cards (card_id,story_id,text,state) VALUES(?,?,?,?)')
        @add_question_stmt = client.prepare('INSERT INTO questions (story_id,card_id,created) VALUES(?,?,NOW())')
        @add_rule_stmt = client.prepare('INSERT INTO rules (story_id,card_id,created) VALUES(?,?,NOW())')
        @add_example_stmt = client.prepare('INSERT INTO examples (rule_card_id,card_id,created) VALUES(?,?,NOW())')
      end

      def call(env)
        return @app.call(env) unless Faye::WebSocket.websocket?(env)

        ws = Faye::WebSocket.new(env)
        story_id = nil

        ws.on :open do |event|
          puts 'OPEN'
          p [:open, ws.object_id]
        end

        ws.on :message do |event|
          puts 'MESSAGE'
          data = JSON.parse(event.data)
          puts "Type = #{data['type']}"
          puts "Story = #{data['story_id']}"
          puts "Packet = #{data.inspect}"

          story_id = data['story_id']
          @clients[story_id] = [] if @clients[story_id].nil?
          @clients[story_id] << ws unless @clients[story_id].include? ws

          case data['type']
          when 'update_card'
            @update_card_query_stmt.execute(data['text'], data['id'])

          when 'add_question'
            id = SecureRandom.uuid
            @add_card_stmt.execute(id, data['story_id'], '', 'saved')
            @add_question_stmt.execute(data['story_id'], id)

          when 'add_rule'
            id = SecureRandom.uuid
            @add_card_stmt.execute(id, data['story_id'], '', 'saved')
            @add_rule_stmt.execute(data['story_id'], id)

          when 'add_example'
            id = SecureRandom.uuid
            @add_card_stmt.execute(id, data['story_id'], '', 'saved')
            @add_example_stmt.execute(data['rule_id'], id)
          end

          @clients[story_id].each do |client|
            client.send({
              type: :update_state,
              state: state(data['story_id'])
            }.to_json)
          end
        end

        ws.on :close do |event|
          begin
          puts 'Closing Down'
          p [:close, event.code, event.reason]
          @clients[story_id].delete(ws)
          @clients.delete(story_id) if @clients[story_id].empty?
          ws = nil
          rescue => e
            puts e.inspect
          end
        end

        ws.rack_response
      rescue => e
        puts e.inspect
      end

      def client
        config = %r(mysql://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^/]+)/(?<db>[^?]+)\?reconnect=true)
                 .match(ENV['CLEARDB_DATABASE_URL'])

        @client ||= Mysql2::Client.new(
          host: config['host'],
          username: config['user'],
          password: config['pass'],
          database: config['db']
        )
      end

      def state(story_id)
        result = {
          cards: {},
          rules: [],
          questions: []
        }
        @fetch_cards_stmt.execute(story_id).each do |row|
          result[:cards][row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym
          }
        end

        row = @fetch_story_stmt.execute(story_id).first
        result[:story_card] = row['story_card']

        result[:questions] = @fetch_questions_stmt.execute(story_id).map do |row|
          row['card_id']
        end

        result[:rules] = @fetch_rules_stmt.execute(story_id).map do |row|
          {
            rule_card: row['card_id'],
            examples: @fetch_examples_stmt.execute(row['card_id']).map do |r|
              r['card_id']
            end
          }
        end

        puts result.inspect

        result
      rescue => e
        puts e.inspect
      end
    end
  end
end
