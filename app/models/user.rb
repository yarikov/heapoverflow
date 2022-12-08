# frozen_string_literal: true

class User < ApplicationRecord
  searchkick searchable: %i[full_name]
  is_impressionable

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: %i[facebook twitter]

  has_one_attached :avatar do |attachable|
    attachable.variant :medium, resize_to_fill: [300, 300]
    attachable.variant :thumb, resize_to_fill: [100, 100]
  end

  has_many :authorizations, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  validates :avatar, content_type: ['image/png', 'image/jpg', 'image/jpeg'], size: { less_than: 2.megabytes }
  validates :full_name, presence: true

  def self.find_for_oauth(auth)
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization
    return new unless auth.info.email

    user = find_or_create_by!(email: auth.info.email) do |u|
      u.full_name = auth.info.name
      # u.remote_avatar_url = auth.info.image
      u.password = Devise.friendly_token[0, 20]
      u.skip_confirmation! if auth.credentials
    end
    user.authorizations.create(provider: auth.provider, uid: auth.uid)
    user
  end

  def author_of?(obj)
    id == obj.user_id
  end

  def vote_up?(obj)
    votes.exists?(votable: obj, value: 1)
  end

  def vote_down?(obj)
    votes.exists?(votable: obj, value: -1)
  end
end
