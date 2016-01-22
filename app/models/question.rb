class Question < ActiveRecord::Base
  include HasVotes

  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :user_id, :title, :body, presence: true

  after_create :author_subscribe

  accepts_nested_attributes_for :attachments, allow_destroy: true

  scope :created_last_24_hours, -> { where(created_at: 1.day.ago..Time.zone.now) }

  private

  def author_subscribe
    subscriptions.create(user: user)
  end
end
