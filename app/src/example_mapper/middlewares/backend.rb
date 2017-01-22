require 'example_mapper/infrastructure/mysql_storage_adapter'
require 'example_mapper/infrastructure/websocket_connections'
require 'faye/websocket'
require 'json'
require 'log4r'
require 'redis'
require 'securerandom'

module ExampleMapper
  module Middlewares
    class Backend
      include Log4r

      KEEPALIVE_TIME = 15

      CHANNEL = 'message-queue'.freeze

      def initialize(app)
        @logger = Logger.new(ENV['DYNO'])
        @logger.outputters = Outputter.stdout
        @logger.level = Object.const_get("Log4r::#{ENV['LOG_LEVEL']}")

        @logger.info 'Initialising instance'

        @app         = app
        @clients     = {}
        @connections = Infrastructure::WebsocketConnections.new
        @storage     = Infrastructure::MysqlStorageAdapter.new(@logger)

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

      def call(env)
        with_error_handling do
          return @app.call(env.merge(storage: @storage)) unless Faye::WebSocket.websocket?(env)

          ws = Faye::WebSocket.new(env)
          story_id = File.basename(env['REQUEST_PATH'])
          client_id = SecureRandom.uuid

          ws.on :open do |_event|
            with_error_handling do
              @connections.register(story_id, ws)
              @logger.debug "WebSocket :open, object_id=#{ws.object_id}, story_id=#{story_id}, client_id=#{client_id}"
              ws.send({
                story_id: story_id,
                type: :set_client_id,
                client_id: client_id,
                # Next to are not necesary
                from: client_id,
                client_request_no: 0,
              }.to_json)
            end
          end

          ws.on :message do |event|
            with_error_handling do
              data = JSON.parse(event.data)
              request_no = data['request_no']

              @logger.debug 'WebSocket :message, type=%s, story_id=%s, client_id=%s, request_no=%s -> %s' %
                [data['type'], story_id, client_id, request_no, data.inspect]

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
                from: client_id,
                client_request_no: request_no,
                type: :update_state,
                state: @storage.fetch_story(story_id)
              }.to_json)
            end
          end

          ws.on :close do |event|
            with_error_handling do
              @logger.debug "WebSocket :close, event.code=#{event.code}, event.reason=#{event.reason}, story_id=#{story_id}, client_id=#{client_id}"
              @connections.release(story_id, ws)
              ws = nil
            end
          end

          ws.rack_response
        end
      end

      def with_error_handling
        yield
      rescue => e
        @logger.error e.inspect
        raise e
      end
    end
  end
end
