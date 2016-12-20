require 'json'
require 'faye/websocket'

module ExampleMapper
  state = {
    cards: {
      'story-card-id' => {
        id: 'story-card-id',
        text: 'This story is great',
        state: :saved
      },
      'rule-card-1-id' => {
        id: 'rule-card-1-id',
        text: 'Everything must be wonderful',
        state: :saved
      },
      'example-card-1-id' => {
        id: 'example-card-1-id',
        text: 'When nothing is bad, then everything is wonderful',
        state: :saved
      },
      'example-card-2-id' => {
        id: 'example-card-2-id',
        text: 'When something is bad, there is an error',
        state: :saved
      },
      'rule-card-2-id' => {
        id: 'rule-card-2-id',
        text: 'I like pizza',
        state: :saved
      },
      'example-card-3-id' => {
        id: 'example-card-3-id',
        text: 'When pizza is present, I am happy',
        state: :saved
      },
      'question-card-1-id' => {
        id: 'question-card-1-id',
        text: 'Why O Why?',
        state: :saved
      },
      'question-card-2-id' => {
        id: 'question-card-2-id',
        text: 'Who dunnit?',
        state: :saved
      }
    },
    story_card: 'story-card-id',
    rules: [
      {
        rule_card: 'rule-card-1-id',
        examples: [
          'example-card-1-id',
          'example-card-2-id'
        ]
      },
      {
        rule_card: 'rule-card-2-id',
        examples: [
          'example-card-3-id'
        ]
      }
    ],
    questions: [
      'question-card-1-id',
      'question-card-2-id'
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

        state[:cards][data['id']][:text] = data['text'] if data['type'] == 'update_card'

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
