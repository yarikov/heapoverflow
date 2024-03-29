# frozen_string_literal: true

class Question < ApplicationRecord
  include HasVotes

  searchkick searchable: %i[title body]

  is_impressionable counter_cache: true, unique: :session_hash
  acts_as_taggable

  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :user_id, :title, :body, :tag_list, presence: true
  validates :title, length: { in: 10..200 }
  validates :body,  length: { in: 10..3000 }

  after_create :author_subscribe

  scope :created_last_24_hours, -> { where(created_at: 1.day.ago..Time.zone.now) }

  private

  def author_subscribe
    subscriptions.create(user: user)
  end
end
