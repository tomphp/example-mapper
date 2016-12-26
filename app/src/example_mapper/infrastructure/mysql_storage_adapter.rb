require 'mysql2'

module ExampleMapper
  module Infrastructure
    class MysqlStorageAdapter
      DB_CONFIG_REGEX = %r{
        mysql://(?<user>[^:]+):(?<pass>[^@]+)@(?<host>[^/]+)/
        (?<db>[^?]+)\?reconnect=true
      }x

      def initialize
        config = DB_CONFIG_REGEX.match(ENV['CLEARDB_DATABASE_URL'])

        @client = Mysql2::Client.new(
          host: config['host'],
          username: config['user'],
          password: config['pass'],
          database: config['db'],
          reconnect: true
        ).tap do |_c|
          puts 'Connected to MySQL database'
        end
      end

      def fetch_story(story_id)
        result = {
          cards: {},
          rules: [],
          questions: []
        }
        fetch_cards(story_id).each do |row|
          result[:cards][row['card_id']] = {
            id: row['card_id'],
            text: row['text'],
            state: row['state'].to_sym
          }
        end

        row = fetch_story_record(story_id).first
        result[:story_card] = row['story_card']

        result[:questions] = fetch_questions(story_id).map do |row|
          row['card_id']
        end

        result[:rules] = fetch_rules(story_id).map do |row|
          {
            rule_card: row['card_id'],
            examples: fetch_examples(row['card_id']).map do |r|
              r['card_id']
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

      def add_story(story_id, card_id, text)
        add_card(card_id, story_id, text, 'saved')
        query('INSERT INTO stories (story_id,story_card) '\
              "VALUES('#{e(story_id)}', '#{e(card_id)}')")
      end

      def add_question(story_id, card_id, text)
        add_card(card_id, story_id, text, 'saved')
        query('INSERT INTO questions (story_id,card_id,created) '\
              "VALUES('#{e(story_id)}','#{e(card_id)}',NOW())")
      end

      def add_rule(story_id, card_id, text)
        add_card(card_id, story_id, text, 'saved')
        query('INSERT INTO rules (story_id,card_id,created) '\
              "VALUES('#{e(story_id)}','#{e(card_id)}',NOW())")
      end

      def add_example(story_id, rule_card_id, card_id, text)
        add_card(card_id, story_id, text, 'saved')
        query('INSERT INTO examples (rule_card_id,card_id,created) '\
              "VALUES('#{e(rule_card_id)}','#{e(card_id)}',NOW())")
      end

      private

      def add_card(card_id, story_id, text, state)
        query('INSERT INTO cards '\
              '(card_id,story_id,text,state) '\
              'VALUES('\
              "'#{e(card_id)}',"\
              "'#{e(story_id)}',"\
              "'#{e(text)}',"\
              "'#{e(state)}'"\
              ')')
      end

      def fetch_story_record(story_id)
        query("SELECT * FROM stories WHERE story_id = '#{e(story_id)}'")
      end

      def fetch_cards(story_id)
        query("SELECT * FROM cards WHERE story_id = '#{e(story_id)}'")
      end

      def fetch_questions(story_id)
        query('SELECT * FROM questions WHERE '\
              "story_id = '#{e(story_id)}' ORDER BY created ASC")
      end

      def fetch_rules(story_id)
        query('SELECT * FROM rules '\
              "WHERE story_id = '#{e(story_id)}' ORDER BY created ASC")
      end

      def fetch_examples(rule_card_id)
        query('SELECT * FROM examples '\
              "WHERE rule_card_id = '#{e(rule_card_id)}' ORDER BY created ASC")
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
