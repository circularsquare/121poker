class DropPlayersTable < ActiveRecord::Migration[6.0]
  def up
    drop_table :players
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
