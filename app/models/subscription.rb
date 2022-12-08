# frozen_string_literal: true

class Subscription < ApplicationRecord
  belongs_to :user
  belongs_to :question

  validates :user_id, :question_id, presence: true
  validates :user_id, uniqueness: { scope: %i[user_id question_id] }
end
