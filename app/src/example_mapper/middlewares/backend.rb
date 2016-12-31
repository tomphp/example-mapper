require 'faye/websocket'
require 'json'
require 'example_mapper/infrastructure/mysql_storage_adapter'
require 'example_mapper/infrastructure/websocket_connections'
require 'securerandom'
require 'redis'

module ExampleMapper
  module Middlewares
    class Backend
      KEEPALIVE_TIME = 15

      CHANNEL = 'message-queue'.freeze

      def initialize(app)
        puts 'Creating the Middleware'

        @app         = app
        @clients     = {}
        @connections = Infrastructure::WebsocketConnections.new
        @storage     = Infrastructure::MysqlStorageAdapter.new

        uri    = URI.parse(ENV['REDIS_URL'])
        @redis = Redis.new(host: uri.host, port: uri.port, password: uri.password)

        Thread.new do
          redis_sub = Redis.new(host: uri.host, port: uri.port, password: uri.password)
          redis_sub.subscribe(CHANNEL) do |on|
            on.message do |_channel, msg|
              with_error_handling do
                story_id = JSON.parse(msg)['story_id']

                @connections.for(story_id).each do |socket|
                  socket.send(msg)
                end
              end
            end
          end
        end
      end

      def with_error_handling
        yield
      rescue => e
        puts e.inspect
        raise e
      end

      def call(env)
        return @app.call(env.merge(storage: @storage)) unless Faye::WebSocket.websocket?(env)

        ws = Faye::WebSocket.new(env)
        story_id = File.basename(env['REQUEST_PATH'])

        ws.on :open do |_event|
          with_error_handling do
            @connections.register(story_id, ws)
            p [:open, ws.object_id, story_id]
          end
        end

        ws.on :message do |event|
          with_error_handling do
            data = JSON.parse(event.data)
            p [:message, data['type'], story_id, data.inspect]

            case data['type']
            when 'update_card'
              @storage.update_card(data['text'], data['id'])

            when 'add_question'
              id = SecureRandom.uuid
              @storage.add_question(story_id, id, data['text'])

            when 'add_rule'
              id = SecureRandom.uuid
              @storage.add_rule(story_id, id, data['text'])

            when 'add_example'
              id = SecureRandom.uuid
              @storage.add_example(story_id, data['rule_id'], id, data['text'])
            end

            @redis.publish(CHANNEL, {
              story_id: story_id,
              type: :update_state,
              state: @storage.fetch_story(story_id)
            }.to_json)
          end
        end

        ws.on :close do |event|
          with_error_handling do
            p [:close, event.code, event.reason, story_id]
            @connections.release(story_id, ws)
            ws = nil
          end
        end

        ws.rack_response
      rescue => e
        puts e.inspect
      end
    end
  end
end
