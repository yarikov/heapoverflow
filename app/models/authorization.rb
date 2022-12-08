# frozen_string_literal: true

class Authorization < ApplicationRecord
  belongs_to :user

  validates :user_id, presence: true
end
