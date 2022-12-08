# frozen_string_literal: true

class Comment < ApplicationRecord
  searchkick searchable: %i[body]

  default_scope { order(created_at: :asc) }

  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :user_id, :body, presence: true
  validates :body, length: { in: 5..200 }
end
