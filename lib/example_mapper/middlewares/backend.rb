require 'faye/websocket'
require 'json'
require 'pg'
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

        db_client.prepare('fetch_story_stmt', 'SELECT * FROM stories WHERE story_id = $1')
        db_client.prepare('fetch_cards_stmt', 'SELECT * FROM cards WHERE story_id = $1')
        db_client.prepare('fetch_questions_stmt', 'SELECT * FROM questions WHERE story_id = $1 ORDER BY created ASC')
        db_client.prepare('fetch_rules_stmt', 'SELECT * FROM rules WHERE story_id = $1 ORDER BY created ASC')
        db_client.prepare('fetch_examples_stmt', 'SELECT * FROM examples WHERE rule_card_id = $1 ORDER BY created ASC')
        db_client.prepare('update_card_query_stmt', 'UPDATE cards SET text = $1 WHERE card_id = $2')
        db_client.prepare('add_story_stmt', 'INSERT INTO stories (story_id,story_card) VALUES($1, $2)')
        db_client.prepare('add_card_stmt', 'INSERT INTO cards (card_id,story_id,text,state) VALUES($1, $2, $3, $4)')
        db_client.prepare('add_question_stmt', 'INSERT INTO questions (story_id,card_id,created) VALUES($1, $2, NOW())')
        db_client.prepare('add_rule_stmt', 'INSERT INTO rules (story_id,card_id,created) VALUES($1, $2, NOW())')
        db_client.prepare('add_example_stmt', 'INSERT INTO examples (rule_card_id,card_id,created) VALUES($1, $2, NOW())')
      end

      def call(env)
        return @app.call(env.merge(db_client: db_client)) unless Faye::WebSocket.websocket?(env)

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
            db_client.exec_prepared('update_card_query_stmt', [data['text'], data['id']])

          when 'add_question'
            id = SecureRandom.uuid
            db_client.exec_prepared('add_card_stmt', [id, data['story_id'], '', 'saved'])
            db_client.exec_prepared('add_question_stmt', [data['story_id'], id])

          when 'add_rule'
            id = SecureRandom.uuid
            db_client.exec_prepared('add_card_stmt', [id, data['story_id'], '', 'saved'])
            db_client.exec_prepared('add_rule_stmt', [data['story_id'], id])

          when 'add_example'
            id = SecureRandom.uuid
            db_client.exec_prepared('add_card_stmt', [id, data['story_id'], '', 'saved'])
            db_client.exec_prepared('add_example_stmt', [data['rule_id'], id])
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

      def db_client
        config = URI.parse(ENV['DATABASE_URL'])

        @db_client ||= PG.connect(
          host: config.host,
          user: config.user,
          password: config.password,
          dbname: config.path[1..-1],
        )
      end

      def state(story_id)
        result = {
          cards: {},
          rules: [],
          questions: []
        }
        db_client.exec_prepared('fetch_cards_stmt', [story_id]).each do |row|
          result[:cards][row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym
          }
        end

        row = db_client.exec_prepared('fetch_story_stmt', [story_id]).first
        result[:story_card] = row['story_card']

        result[:questions] = db_client.exec_prepared('fetch_questions_stmt', [story_id]).map do |row|
          row['card_id']
        end

        result[:rules] = db_client.exec_prepared('fetch_rules_stmt', [story_id]).map do |row|
          {
            rule_card: row['card_id'],
            examples: db_client.exec_prepared('fetch_examples_stmt', [row['card_id']]).map do |r|
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
