class Ability
  include CanCan::Ability

  attr_reader :user

  def initialize(user)
    @user = user

    if user
      user.admin? ? admin_abilities : user_abilities
    else
      guest_abilities
    end
  end

  def admin_abilities
    can :manage, :all
  end

  def user_abilities
    can :read, :all
    can :tagged, [Question]
    can :create,  [Question, Answer, Comment, Subscription]
    can [:update, :destroy], [Question, Answer, Comment, Subscription], user_id: user.id

    can [:update, :me], User, id: user.id

    can [:vote_down, :vote_up], [Question, Answer] do |object|
      !user.author_of?(object)
    end

    can :best, Answer do |answer|
      user.author_of?(answer.question)
    end
  end

  def guest_abilities
    can :read, :all
    can :tagged, [Question]
  end
end
