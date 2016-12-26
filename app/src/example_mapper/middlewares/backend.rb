require 'faye/websocket'
require 'json'
require 'example_mapper/infrastructure/mysql_storage_adapter'
require 'securerandom'

module ExampleMapper
  module Middlewares
    class Backend
      KEEPALIVE_TIME = 15

      def initialize(app)
        puts 'Creating the Middleware'

        @app     = app
        @clients = {}
        @storage = Infrastructure::MysqlStorageAdapter.new
      end

      def call(env)
        return @app.call(env.merge(storage: @storage)) unless Faye::WebSocket.websocket?(env)

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
            @storage.update_card_query(data['text'], data['id'])

          when 'add_question'
            id = SecureRandom.uuid
            @storage.add_card(id, data['story_id'], '', 'saved')
            @storage.add_question(data['story_id'], id)

          when 'add_rule'
            id = SecureRandom.uuid
            @storage.add_card(id, data['story_id'], '', 'saved')
            @storage.add_rule(data['story_id'], id)

          when 'add_example'
            id = SecureRandom.uuid
            @storage.add_card(id, data['story_id'], '', 'saved')
            @storage.add_example(data['rule_id'], id)
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

      def state(story_id)
        result = {
          cards: {},
          rules: [],
          questions: []
        }
        @storage.fetch_cards(story_id).each do |row|
          result[:cards][row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym
          }
        end

        row = @storage.fetch_story(story_id).first
        result[:story_card] = row['story_card']

        result[:questions] = @storage.fetch_questions(story_id).map do |row|
          row['card_id']
        end

        result[:rules] = @storage.fetch_rules(story_id).map do |row|
          {
            rule_card: row['card_id'],
            examples: @storage.fetch_examples(row['card_id']).map do |r|
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
