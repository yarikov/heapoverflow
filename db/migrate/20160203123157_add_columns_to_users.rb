class AddColumnsToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :full_name, :string
    add_column :users, :avatar, :string
    add_column :users, :location, :string
    add_column :users, :description, :text
    add_column :users, :github, :string
    add_column :users, :website, :string
    add_column :users, :twitter, :string
  end
end
