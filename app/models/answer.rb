# frozen_string_literal: true

class Answer < ApplicationRecord
  include HasVotes

  searchkick searchable: %i[body]

  belongs_to :question, counter_cache: true
  belongs_to :user

  has_many :comments, -> { order(created_at: :asc) }, as: :commentable, dependent: :destroy, inverse_of: :commentable

  validates :body, :question_id, :user_id, presence: true
  validates :body, length: { in: 10..3000 }
end
