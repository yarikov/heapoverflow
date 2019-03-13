class AddBestToAnswers < ActiveRecord::Migration[4.2]
  def change
    add_column :answers, :best, :boolean, default: false
  end
end
