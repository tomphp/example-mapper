require 'mysql2'

module ExampleMapper
  module Infrastructure
    class MysqlStorageAdapter
      def initialize(logger)
        @logger = logger

        config = URI.parse(ENV['CLEARDB_DATABASE_URL'])
        query = Rack::Utils.parse_nested_query(config.query)

        @client = Mysql2::Client.new(
          host: config.hostname,
          username: config.user,
          password: config.password,
          database: File.basename(config.path),
          reconnect: query['reconnect'] == 'true'
        ).tap do |_c|
          @logger.info 'Connected to MySQL database'
        end
      end

      def fetch_story(story_id)
        story_card = fetch_story_record(story_id).first

        return if story_card.nil?

        result = {
          story_card: format_card(story_card),
          rules: fetch_rules(story_id).map do |row|
            {
              rule_card: format_card(row),
              examples: fetch_examples(row['card_id']).map { |r| format_card(r) }
            }
          end,
          questions: fetch_questions(story_id).map { |row| format_card(row) }
        }

        result.tap { |r| @logger.debug "Response: #{r.inspect}" }
      rescue => e
        @logger.error e.inspect + e.backtrace.inspect
      end

      def update_card(text, card_id)
        transaction do
          version = next_version(card_id)
          query('UPDATE cards '\
                "SET text = '#{e(text)}', version = #{version} "\
                "WHERE card_id = '#{e(card_id)}'")
        end
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
        @logger.error e.inspect + e.backtrace.inspect
      end

      def add_example(story_id, rule_card_id, card_id, text)
        transaction do
          position = next_position(story_id, 'example')
          add_card(card_id, story_id, 'example', text, 'saved', position)
          query('INSERT INTO examples (rule_card_id,card_id) '\
                "VALUES('#{e(rule_card_id)}','#{e(card_id)}')")
        end
      end

      def delete_question(id)
        delete_card(id)
      end

      def delete_example(id)
        transaction do
          delete_card(id)
          query("DELETE FROM examples WHERE card_id = '#{e(id)}'")
        end
      end

      def delete_rule(id)
        transaction do
          fetch_examples(id).each do |example|
            delete_card(example['card_id'])
          end
          query("DELETE FROM examples WHERE rule_card_id = '#{e(id)}'")
          delete_card(id)
        end
      end

      private

      def delete_card(id)
        query("DELETE FROM cards WHERE card_id = '#{e(id)}'")
      end

      def format_card(row)
        {
          id: row['card_id'],
          text: row['text'],
          state: row['state'],
          position: row['position'],
          version: row['version']
        }
      end

      def transaction
        raise ArgumentError, 'No block was given' unless block_given?

        begin
          query('BEGIN')
          yield
          query('COMMIT')
        rescue => e
          query('ROLLBACK')
          @logger.error "MySQL transaction failed: #{e.inspect}"
        end
      end

      def add_card(card_id, story_id, type, text, state, position)
        query(%(
        INSERT INTO cards
          (card_id,story_id,type,text,state,position,version)
          VALUES(
            '#{e(card_id)}',
            '#{e(story_id)}',
            '#{e(type)}',
            '#{e(text)}',
            '#{e(state)}',
            '#{e(position.to_s)}',
            1
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
        query('SELECT cards.* FROM examples INNER JOIN cards USING (card_id) '\
              "WHERE rule_card_id = '#{e(rule_card_id)}'")
      end

      def next_position(story_id, type)
        max_pos = query(%(
          SELECT MAX(position) AS position
          FROM cards
          WHERE story_id = '#{e(story_id)}' AND type = '#{e(type)}'
        )).first['position']

        max_pos.nil? ? 0 : (max_pos + 1)
      end

      def next_version(card_id)
        query(%(
          SELECT version
          FROM cards
          WHERE card_id = '#{e(card_id)}'
        )).first['version'] + 1
      end

      def query(sql)
        @logger.debug "MySQL Query: #{sql}"
        time('Query') do
          @client.query(sql)
        end
      end

      def e(value)
        @client.escape(value)
      end

      def time(name)
        start = Time.now

        yield.tap { @logger.debug "#{name} took #{Time.now - start}" }
      end
    end
  end
end
