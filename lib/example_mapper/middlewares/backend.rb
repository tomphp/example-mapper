require 'faye/websocket'
require 'json'
require 'mysql2'
require 'securerandom'

module ExampleMapper
  module Middlewares
    class Backend
      KEEPALIVE_TIME = 15

      def initialize(app)
        puts 'Creating the Middleware'

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
      end

      def call(env)
        return @app.call(env.merge(mysql_client: client)) unless Faye::WebSocket.websocket?(env)

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
            update_card_query(data['text'], data['id'])

          when 'add_question'
            id = SecureRandom.uuid
            add_card(id, data['story_id'], '', 'saved')
            add_question(data['story_id'], id)

          when 'add_rule'
            id = SecureRandom.uuid
            add_card(id, data['story_id'], '', 'saved')
            add_rule(data['story_id'], id)

          when 'add_example'
            id = SecureRandom.uuid
            add_card(id, data['story_id'], '', 'saved')
            add_example(data['rule_id'], id)
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
          unless @clients[story_id].nil?
            @clients[story_id].delete(ws)
            @clients.delete(story_id) if @clients[story_id].empty?
          end
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
          database: config['db'],
          reconnect: true
        ).tap do |c|
          puts 'Creating in the Middleware'
        end
      end

      def state(story_id)
        result = {
          cards: {},
          rules: [],
          questions: []
        }
        fetch_cards(story_id).each do |row|
          result[:cards][row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym
          }
        end

        row = fetch_story(story_id).first
        result[:story_card] = row['story_card']

        result[:questions] = fetch_questions(story_id).map do |row|
          row['card_id']
        end

        result[:rules] = fetch_rules(story_id).map do |row|
          {
            rule_card: row['card_id'],
            examples: fetch_examples(row['card_id']).map do |r|
              r['card_id']
            end
          }
        end

        puts result.inspect

        result
      rescue => e
        puts e.inspect
      end

      def fetch_story(story_id)
        story_id = client.escape(story_id)
        client.query("SELECT * FROM stories WHERE story_id = '#{story_id}'")
      end

      def fetch_cards(story_id)
        story_id = client.escape(story_id)
        client.query("SELECT * FROM cards WHERE story_id = '#{story_id}'")
      end

      def fetch_questions(story_id)
        story_id = client.escape(story_id)
        client.query("SELECT * FROM questions WHERE story_id = '#{story_id}' ORDER BY created ASC")
      end

      def fetch_rules(story_id)
        story_id = client.escape(story_id)
        client.query("SELECT * FROM rules WHERE story_id = '#{story_id}' ORDER BY created ASC")
      end

      def fetch_examples(rule_card_id)
        rule_card_id = client.escape(rule_card_id)
        client.query("SELECT * FROM examples WHERE rule_card_id = '#{rule_card_id}' ORDER BY created ASC")
      end

      def update_card_query(text, card_id)
        text = client.escape(text)
        card_id = client.escape(card_id)
        client.query("UPDATE cards SET text = '#{text}' WHERE card_id = '#{card_id}'")
      end

      def add_card(card_id, story_id, text, state)
        card_id = client.escape(card_id)
        story_id = client.escape(story_id)
        text = client.escape(text)
        state = client.escape(state)
        client.query("INSERT INTO cards (card_id,story_id,text,state) VALUES('#{card_id}','#{story_id}','#{text}','#{state}')")
      end

      def add_question(story_id, card_id)
        story_id = client.escape(story_id)
        card_id = client.escape(card_id)
        client.query("INSERT INTO questions (story_id,card_id,created) VALUES('#{story_id}','#{card_id}',NOW())")
      end

      def add_rule(story_id, card_id)
        story_id = client.escape(story_id)
        card_id = client.escape(card_id)
        client.query("INSERT INTO rules (story_id,card_id,created) VALUES('#{story_id}','#{card_id}',NOW())")
      end

      def add_example(rule_card_id, card_id)
        rule_card_id = client.escape(rule_card_id)
        card_id = client.escape(card_id)
        client.query("INSERT INTO examples (rule_card_id,card_id,created) VALUES('#{rule_card_id}','#{card_id}',NOW())")
      end
    end
  end
end
