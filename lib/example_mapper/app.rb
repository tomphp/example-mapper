require 'json'
require 'faye/websocket'
require 'securerandom'

module ExampleMapper
  story_id = SecureRandom.uuid
  state = {
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

  clients = []

  App = lambda do |env|
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      ws.on :open do |_event|
        p [:open, ws.object_id]
        clients << ws
      end

      ws.on :message do |event|
        data = JSON.parse(event.data)
        puts "Type = #{data['type']}"
        puts "Packet = #{data.inspect}"

        case data['type']
        when 'update_card'
          state[:cards][data['id']][:text] = data['text']

        when 'add_question'
          id = SecureRandom.uuid
          state[:cards][id] = {
            id: id,
            text: '',
            state: :saved
          }
          state[:questions] << id

        when 'add_rule'
          id = SecureRandom.uuid
          state[:cards][id] = {
            id: id,
            text: '',
            state: :saved
          }
          state[:rules] << { rule_card: id, examples: [] }

        when 'add_example'
          id = SecureRandom.uuid
          state[:cards][id] = {
            id: id,
            text: '',
            state: :saved
          }
          state[:rules][data['rule_id']][:examples] << id

        end

        clients.each do |client|
          client.send({
            type: :update_state,
            state: state
          }.to_json)
        end
      end

      ws.on :close do |event|
        puts 'Closing Down'
        p [:close, event.code, event.reason]
        clients.delete(ws)
        ws = nil
      end

      ws.rack_response

    else
      [200, { 'Content-Type' => 'text/plain' }, ['Hello Fuck Face']]
    end
  end
end
