class CardPositions < ActiveRecord::Migration
  def up
    execute %(
      ALTER TABLE cards
      ADD COLUMN position INTEGER UNSIGNED NOT NULL DEFAULT 0
      AFTER state
    )

    execute %(
      ALTER TABLE cards
      ADD COLUMN type ENUM('story','rule','example','question')
      AFTER story_id
    )

    execute('SELECT story_id FROM stories').each do |row|
      story_id = row[0]
      execute "UPDATE cards SET type='story' WHERE card_id='#{story_id}'"
    end

    execute('SELECT card_id,position FROM rules').each do |row|
      card_id = row[0]
      position = row[1]
      execute %(
        UPDATE cards
        SET type='rule', position='#{position}'
        WHERE card_id='#{card_id}'
      )
    end

    execute('SELECT card_id FROM examples').each do |row|
      card_id = row[0]
      execute "UPDATE cards SET type='example' WHERE card_id='#{card_id}'"
    end

    execute('SELECT card_id FROM questions').each do |row|
      card_id = row[0]
      execute "UPDATE cards SET type='question' WHERE card_id='#{card_id}'"
    end

    execute 'DROP TABLE stories'
    execute 'DROP TABLE questions'
    execute 'DROP TABLE rules'
    execute 'ALTER TABLE examples DROP COLUMN created'
  end

  def down
    raise '#down not implemented'
  end
end
