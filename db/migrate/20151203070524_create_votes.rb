class CreateVotes < ActiveRecord::Migration[4.2]
  def change
    create_table :votes do |t|
      t.integer :value
      t.integer :votable_id
      t.string :votable_type
      t.belongs_to :user, index: true, foreign_key: true

      t.timestamps null: false
    end

    add_index :votes, [:votable_id, :votable_type]
  end
end
