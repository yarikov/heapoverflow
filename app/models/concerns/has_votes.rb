module HasVotes
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy
  end

  def vote_count
    votes.sum(:value)
  end
end
