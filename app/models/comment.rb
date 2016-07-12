class Comment < ApplicationRecord
  default_scope { order(created_at: :asc) }

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :user_id, :body, presence: true
  validates :body, length: { in: 5..200 }
end
