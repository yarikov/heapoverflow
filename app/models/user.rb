class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :questions, dependent: :destroy
  has_many :answers, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :votes, dependent: :destroy
  has_many :subscriptions, dependent: :destroy

  devise :database_authenticatable, :registerable, :confirmable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook, :twitter]

  def self.find_for_oauth(auth)
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization
    return new unless auth.info.email
    user = find_or_create_by!(email: auth.info.email) do |u|
      u.password = Devise.friendly_token[0, 20]
      u.skip_confirmation! if auth.credentials
    end
    user.authorizations.create(provider: auth.provider, uid: auth.uid)
    user
  end

  def vote_up(obj)
    return votes.find_by(votable: obj).destroy if vote_up?(obj)
    return votes.find_by(votable: obj).update(value: 1) if vote_down?(obj)
    votes.create(votable: obj, value: 1)
  end

  def vote_down(obj)
    return votes.find_by(votable: obj).destroy if vote_down?(obj)
    return votes.find_by(votable: obj).update(value: -1) if vote_up?(obj)
    votes.create(votable: obj, value: -1)
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
