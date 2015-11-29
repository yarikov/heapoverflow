class Answer < ActiveRecord::Base
  default_scope { order('best DESC') }

  belongs_to :question
  belongs_to :user

  has_many :attachments, as: :attachable

  validates :body, :question_id, :user_id, presence: true

  accepts_nested_attributes_for :attachments, allow_destroy: true

  def best!
    best_answer = question.answers.find_by(best: true)
    best_answer.update(best: false) if best_answer
    update(best: true)
  end
end
