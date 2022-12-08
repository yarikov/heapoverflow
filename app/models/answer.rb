# frozen_string_literal: true

class Answer < ApplicationRecord
  include HasVotes

  searchkick searchable: %i[body]

  belongs_to :question
  belongs_to :user

  has_many :comments, as: :commentable, dependent: :destroy

  validates :body, :question_id, :user_id, presence: true
  validates :body, length: { in: 10..3000 }

  after_create :notify_subscribers

  def best!
    transaction do
      question.answers.where(best: true).update(best: false)
      update(best: true)
    end
  end

  def notify_subscribers
    NotifySubscribersJob.perform_later(self)
  end
end
