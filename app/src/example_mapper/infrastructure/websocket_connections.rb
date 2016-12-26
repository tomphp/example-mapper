module ExampleMapper
  module Infrastructure
    class WebsocketConnections
      def initialize
        @connections = {}
      end

      def register(story_id, connection)
        @connections[story_id] = [] if @connections[story_id].nil?
        @connections[story_id] << connection
      end

      def release(story_id, connection)
        @connections[story_id].delete(connection) if @connections.key? story_id
      end

      def for(story_id)
        @connections[story_id] || []
      end
    end
  end
end
