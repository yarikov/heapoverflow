# frozen_string_literal: true

module HasVotes
  extend ActiveSupport::Concern

  included do
    has_many :votes, as: :votable, dependent: :destroy

    scope :with_votes_sum, lambda {
      select("#{table_name}.*, COALESCE(SUM(votes.value), 0) AS votes_sum")
        .left_joins(:votes)
        .group("#{table_name}.id")
    }
  end

  def votes_sum
    self[:votes_sum] || votes.sum(:value)
  end
end
