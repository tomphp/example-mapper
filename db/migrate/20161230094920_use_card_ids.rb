class UseCardIds < ActiveRecord::Migration
  def up
    execute('SELECT story_id,story_card FROM stories').each do |story|
      puts story.inspect
      story_id = story[0]
      card_id = story[1]

      execute("UPDATE cards SET card_id = '#{story_id}' "\
              "WHERE card_id = '#{card_id}'")
    end

    execute('ALTER TABLE stories DROP COLUMN story_card')
  end

  def down
    raise 'Can\'t migrate down!'
  end
end
