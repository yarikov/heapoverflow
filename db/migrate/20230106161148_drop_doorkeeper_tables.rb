class DropDoorkeeperTables < ActiveRecord::Migration[7.0]
  def up
    drop_table :oauth_access_grants
    drop_table :oauth_access_tokens
    drop_table :oauth_applications
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
