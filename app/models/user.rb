class User < ActiveRecord::Base
  has_many :authorizations, dependent: :destroy
  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable,
         :omniauthable, omniauth_providers: [:facebook]

  def self.find_for_oauth(auth)
    authorization = Authorization.find_by(provider: auth.provider, uid: auth.uid.to_s)
    return authorization.user if authorization

    email = auth.info[:email]
    user = User.find_by(email: email)

    if user
      user.authorizations.create(provider: auth.provider, uid: auth.uid)
    else
      password = Devise.friendly_token[0, 20]
      user = User.create!(email: email, password: password, password_confirmation: password)
      user.authorizations.create(provider: auth.provider, uid: auth.uid)
    end
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
