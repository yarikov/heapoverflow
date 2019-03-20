class CreateAttachments < ActiveRecord::Migration[4.2]
  def change
    create_table :attachments do |t|
      t.string :file
      t.integer :attachable_id
      t.string :attachable_type

      t.timestamps null: false
    end

    add_index :attachments, [:attachable_id, :attachable_type]
  end
end
