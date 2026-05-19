# frozen_string_literal: true

class User < ApplicationRecord
  searchkick searchable: %i[full_name]
  is_impressionable

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook twitter]

  has_one_attached :avatar do |attachable|
    attachable.variant :medium, resize_to_fill: [320, 320]
    attachable.variant :thumb, resize_to_fill: [100, 100]
  end

  has_many :authorizations, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :avatar, content_type: ['image/png', 'image/jpeg'], size: { less_than: 2.megabytes }
  validates :full_name, presence: true

  scope :with_attached_avatar, -> { includes(avatar_attachment: :blob) }

  def author_of?(obj)
    id == obj.user_id
  end

  def vote_up?(obj, preloaded_votes = nil)
    if preloaded_votes
      preloaded_votes.any? do |vote|
        vote.votable_id == obj.id && vote.votable_type == obj.class.to_s && vote.value == 1
      end
    else
      votes.exists?(votable: obj, value: 1)
    end
  end

  def vote_down?(obj, preloaded_votes = nil)
    if preloaded_votes
      preloaded_votes.any? do |vote|
        vote.votable_id == obj.id && vote.votable_type == obj.class.to_s && vote.value == -1
      end
    else
      votes.exists?(votable: obj, value: -1)
    end
  end
end
