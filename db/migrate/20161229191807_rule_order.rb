class RuleOrder < ActiveRecord::Migration
  def up
    execute %(
      ALTER TABLE `rules`
      ADD COLUMN `position` INT UNSIGNED NOT NULL DEFAULT 0
      AFTER `created`
    )

    execute %(
      ALTER TABLE `rules`
      DROP COLUMN `created`
    )
  end

  def down
    execute %(
      ALTER TABLE `rules`
      ADD COLUMN `created` datetime NOT NULL,
      BEFORE `position`
    )

    execute %(
      ALTER TABLE `rules`
      DROP COLUMN `position`
    )
  end
end
