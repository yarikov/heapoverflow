class DropAttachments < ActiveRecord::Migration[7.0]
  def up
    drop_table :attachments
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
