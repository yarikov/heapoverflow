class Question < ActiveRecord::Base
  include HasVotes

  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy

  validates :user_id, :title, :body, presence: true

  accepts_nested_attributes_for :attachments, allow_destroy: true

  scope :created_last_24_hours, -> { where(created_at: 1.day.ago..Time.zone.now) }
end
