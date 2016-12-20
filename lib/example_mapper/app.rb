require 'json'
require 'faye/websocket'

module ExampleMapper
  state = {
    story_card: {
      text: 'This story is great',
      state: :saved
    },
    rules: [
      {
        rule_card: {
          text: 'Everything must be wonderful',
          state: :saved
        },
        examples: [
          {
            text: 'When nothing is bad, then everything is wonderful',
            state: :saved
          },
          {
            text: 'When something is bad, there is an error',
            state: :saved
          }
        ]
      },
      {
        rule_card: {
          text: 'I like pizza',
          state: :saved
        },
        examples: [
          {
            text: 'When pizza is present, I am happy',
            state: :saved
          }
        ]
      }
    ],
    questions: [
      {
        text: 'Why O Why?',
        state: :saved
      },
      {
        text: 'Who dunnit?',
        state: :saved
      }
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

        state[:story_card][:text] = data['text'] if data['type'] == 'update_story_card'

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
