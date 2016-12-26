require 'faye/websocket'
require 'json'
require 'example_mapper/infrastructure/mysql_storage_adapter'
require 'example_mapper/infrastructure/websocket_connections'
require 'securerandom'

module ExampleMapper
  module Middlewares
    class Backend
      KEEPALIVE_TIME = 15

      def initialize(app)
        puts 'Creating the Middleware'

        @app         = app
        @clients     = {}
        @connections = Infrastructure::WebsocketConnections.new
        @storage     = Infrastructure::MysqlStorageAdapter.new
      end

      def call(env)
        return @app.call(env.merge(storage: @storage)) unless Faye::WebSocket.websocket?(env)

        ws = Faye::WebSocket.new(env)
        story_id = nil

        ws.on :open do |event|
          begin
            story_id = File.basename(env['REQUEST_PATH'])
            @connections.register(story_id, ws)
            p [:open, ws.object_id, story_id]
          rescue => e
            puts e.inspect
          end
        end

        ws.on :message do |event|
          begin
            data = JSON.parse(event.data)
            p [:message, data['type'], story_id, data.inspect]

            case data['type']
            when 'update_card'
              @storage.update_card(data['text'], data['id'])

            when 'add_question'
              id = SecureRandom.uuid
              @storage.add_question(story_id, id, '')

            when 'add_rule'
              id = SecureRandom.uuid
              @storage.add_rule(story_id, id, '')

            when 'add_example'
              id = SecureRandom.uuid
              @storage.add_example(story_id, data['rule_id'], id, '')
            end

            @connections.for(story_id).each do |socket|
              socket.send({
                type: :update_state,
                state: @storage.fetch_story(story_id)
              }.to_json)
            end
          rescue => e
            puts e.inspect
          end
        end

        ws.on :close do |event|
          begin
            p [:close, event.code, event.reason, story_id]
            @connections.release(story_id, ws)
            ws = nil
          rescue => e
            puts e.inspect
          end
        end

        ws.rack_response
      rescue => e
        puts e.inspect
      end
    end
  end
end
