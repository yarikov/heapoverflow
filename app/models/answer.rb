class Answer < ApplicationRecord
  include HasVotes

  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :body, :question_id, :user_id, presence: true
  validates :body, length: { in: 10..3000 }

  accepts_nested_attributes_for :attachments, reject_if: :all_blank, allow_destroy: true

  after_create :notify_subscribers

  def best!
    best_answer = question.answers.find_by(best: true)
    best_answer.update(best: false) if best_answer
    update(best: true)
  end

  def notify_subscribers
    NotifySubscribersJob.perform_later(self)
  end
end
