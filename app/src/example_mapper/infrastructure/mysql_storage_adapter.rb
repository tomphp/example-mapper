require 'mysql2'

module ExampleMapper
  module Infrastructure
    class MysqlStorageAdapter
      def initialize
        config = URI.parse(ENV['CLEARDB_DATABASE_URL'])
        query = Rack::Utils.parse_nested_query(config.query)

        @client = Mysql2::Client.new(
          host: config.hostname,
          username: config.user,
          password: config.password,
          database: File.basename(config.path),
          reconnect: query['reconnect'] == 'true'
        ).tap do |_c|
          puts 'Connected to MySQL database'
        end
      end

      def fetch_story(story_id)
        result = {
          rules: [],
          questions: []
        }

        cards = {}
        fetch_cards(story_id).each do |row|
          cards[row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym,
            position: row['position']
          }
        end

        fetch_story_record(story_id).first.tap do |row|
          result[:story_card] = cards[row['story_id']]
        end

        fetch_questions(story_id).each do |row|
          result[:questions] << cards[row['card_id']]
        end

        result[:rules] = fetch_rules(story_id).map do |row|
          {
            rule_card: cards[row['card_id']],
            examples: fetch_examples(row['card_id']).map do |r|
              cards[r['card_id']]
            end
          }
        end

        puts result.inspect

        result
      rescue => e
        puts e.inspect
      end

      def update_card(text, card_id)
        query('UPDATE cards '\
              "SET text = '#{e(text)}' WHERE card_id = '#{e(card_id)}'")
      end

      def add_story(story_id, text)
        add_card(story_id, story_id, 'story', text, 'saved', 0)
      end

      def add_question(story_id, card_id, text)
        transaction do
          position = next_position(story_id, 'question')
          add_card(card_id, story_id, 'question', text, 'saved', position)
        end
      end

      def add_rule(story_id, card_id, text)
        transaction do
          position = next_position(story_id, 'rule')
          add_card(card_id, story_id, 'rule', text, 'saved', position)
        end
      rescue => e
        puts e.inspect
      end

      def add_example(story_id, rule_card_id, card_id, text)
        transaction do
          position = next_position(story_id, 'example')
          add_card(card_id, story_id, 'example', text, 'saved', position)
          query('INSERT INTO examples (rule_card_id,card_id) '\
                "VALUES('#{e(rule_card_id)}','#{e(card_id)}')")
        end
      end

      private

      def transaction
        raise ArgumentError, 'No block was given' unless block_given?

        begin
          query('BEGIN')
          yield
          query('COMMIT')
        rescue => e
          query('ROLLBACK')
          puts "Transaction failed: #{e.inspect}"
        end
      end

      def add_card(card_id, story_id, type, text, state, position)
        query(%(
        INSERT INTO cards
          (card_id,story_id,type,text,state,position)
          VALUES(
            '#{e(card_id)}',
            '#{e(story_id)}',
            '#{e(type)}',
            '#{e(text)}',
            '#{e(state)}',
            '#{e(position.to_s)}'
          )
        ))
      end

      def fetch_story_record(story_id)
        query("SELECT * FROM cards WHERE card_id = '#{e(story_id)}'")
      end

      def fetch_cards(story_id)
        query("SELECT * FROM cards WHERE story_id = '#{e(story_id)}'")
      end

      def fetch_questions(story_id)
        query('SELECT * FROM cards WHERE '\
              "story_id = '#{e(story_id)}' AND type='question' "\
              'ORDER BY position ASC')
      end

      def fetch_rules(story_id)
        query('SELECT * FROM cards '\
              "WHERE story_id = '#{e(story_id)}' AND type='rule' "\
              'ORDER BY position ASC')
      end

      def fetch_examples(rule_card_id)
        query('SELECT * FROM examples '\
              "WHERE rule_card_id = '#{e(rule_card_id)}'")
      end

      def next_position(story_id, type)
        max_pos = query(%(
          SELECT MAX(position) AS position
          FROM cards
          WHERE story_id = '#{e(story_id)}' AND type = '#{e(type)}'
        )).first['position']

        puts "POSITION: #{max_pos.inspect}"

        max_pos.nil? ? 0 : (max_pos + 1)
      end

      def query(sql)
        @client.query(sql)
      end

      def e(value)
        @client.escape(value)
      end
    end
  end
end
