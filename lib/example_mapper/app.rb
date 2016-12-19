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

  App = lambda do |env|
    if Faye::WebSocket.websocket?(env)
      ws = Faye::WebSocket.new(env)

      ws.on :message do |event|
        puts "Message #{event.inspect}"
        ws.send({
          type: :update_state,
          state: state
        }.to_json)
      end

      ws.on :close do |event|
        puts 'Closing Down'
        p [:close, event.code, event.reason]
        ws = nil
      end

      ws.rack_response

    else
      [200, { 'Content-Type' => 'text/plain' }, ['Hello Fuck Face']]
    end
  end
end
