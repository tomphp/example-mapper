class AddCardVersion < ActiveRecord::Migration
  def up
    execute %(
      ALTER TABLE cards
      ADD COLUMN version INTEGER UNSIGNED NOT NULL DEFAULT 0
      AFTER state
    )
  end
end
