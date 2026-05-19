# frozen_string_literal: true

class Answer < ApplicationRecord
  include HasVotes

  searchkick searchable: %i[body]

  belongs_to :question, counter_cache: true
  belongs_to :user

  has_many :comments, -> { order(created_at: :asc) }, as: :commentable, dependent: :destroy, inverse_of: :commentable

  validates :body, :question_id, :user_id, presence: true
  validates :body, length: { in: 10..3000 }

  def best!
    transaction do
      question.answers.where(best: true).update(best: false)
      update(best: true)
    end
  end
end
