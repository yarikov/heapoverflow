# frozen_string_literal: true

class Vote < ApplicationRecord
  belongs_to :user
  belongs_to :votable, polymorphic: true

  validates :value, presence: true
  validates :user_id, uniqueness: { scope: %i[votable_id votable_type] }
end
