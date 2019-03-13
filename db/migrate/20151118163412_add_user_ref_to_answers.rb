class AddUserRefToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_reference :answers, :user, index: true, foreign_key: true
  end
end
