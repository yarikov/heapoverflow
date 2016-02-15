class Question < ActiveRecord::Base
  include HasVotes
  is_impressionable
  acts_as_taggable

  default_scope { order('created_at DESC') }

  belongs_to :user

  has_many :answers, dependent: :destroy
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :user_id, :title, :body, :tag_list, presence: true
  validates :title, length: { in: 10..200 }
  validates :body,  length: { in: 10..3000 }

  after_create :author_subscribe

  accepts_nested_attributes_for :attachments, reject_if: :all_blank, allow_destroy: true

  scope :created_last_24_hours, -> { where(created_at: 1.day.ago..Time.zone.now) }

  private

  def author_subscribe
    subscriptions.create(user: user)
  end
end
