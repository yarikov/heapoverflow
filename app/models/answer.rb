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
    best_answer = question.answers.find_by(best: true)
    best_answer.update(best: false) if best_answer
    update(best: true)
  end

  def notify_subscribers
    NotifySubscribersJob.perform_later(self)
  end
end
