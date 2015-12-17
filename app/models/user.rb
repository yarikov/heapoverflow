class User < ActiveRecord::Base
  has_many :questions
  has_many :answers
  has_many :comments
  has_many :votes, dependent: :destroy

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

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
