class AddMissingUniqueIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :subscriptions, %i[user_id question_id], unique: true
    add_index :votes, %i[user_id votable_id votable_type], unique: true
  end
end
