class AddUserRefToQuestions < ActiveRecord::Migration[4.2]
  def change
    add_reference :questions, :user, index: true, foreign_key: true
  end
end
