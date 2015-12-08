class Question < ActiveRecord::Base
  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :votes, as: :votable, dependent: :destroy

  validates :user_id, :title, :body, presence: true

  accepts_nested_attributes_for :attachments, allow_destroy: true

  def vote_count
    votes.sum(:value)
  end
end
