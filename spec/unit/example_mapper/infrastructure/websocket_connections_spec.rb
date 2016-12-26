require 'example_mapper/infrastructure/websocket_connections'

module ExampleMapper
  module Infrastructure
    describe WebsocketConnections do
      subject { WebsocketConnections.new }

      before do
        subject.register('story1', 'conn1')
        subject.register('story2', 'conn2')
        subject.register('story1', 'conn3')
      end

      describe '#for' do
        it 'returns all the connections for a given story' do
          expect(subject.for('story1')).to eq %w(conn1 conn3)
        end

        it 'returns an empty array if requesting an unknown story' do
          expect(subject.for('story3')).to eq []
        end
      end

      describe '#release' do
        it 'releases a connection' do
          subject.release('story1', 'conn1')

          expect(subject.for('story1')).to eq %w(conn3)
        end

        it 'does nothing if the connection is unknown' do
          subject.release('story1', 'unknown')
        end

        it 'does nothing if the story is unknown' do
          subject.release('unknown', 'conn9')
        end
      end
    end
  end
end
