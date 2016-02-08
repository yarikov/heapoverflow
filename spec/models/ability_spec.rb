require 'rails_helper'

RSpec.describe Ability, type: :model do
  subject(:ability) { Ability.new(user) }

  describe 'for guest' do
    let(:user) { nil }

    it { should_not be_able_to :manage, :all }

    it { should be_able_to :read, Question }
    it { should be_able_to :read, Answer }
    it { should be_able_to :read, Comment }
    it { should be_able_to :read, User }
  end

  describe 'for admin' do
    let(:user) { create :user, admin: true }

    it { should be_able_to :manage, :all }
  end

  describe 'for user' do
    let(:user) { create :user }
    let(:other) { create :user }

    let(:own_question) { create :question, user: user }
    let(:other_question) { create :question, user: other }

    let(:own_answer) { create :answer, question: own_question, user: user }
    let(:other_answer) { create :answer, question: own_question, user: other }
    let(:other_answer2) { create :answer, question: other_question, user: other }

    let(:own_comment)   { create :comment, commentable: own_question, user: user }
    let(:other_comment) { create :comment, commentable: own_question, user: other }

    let(:own_subscription) { own_question.subscriptions.first }
    let(:other_subscription) { create :subscription }

    it { should_not be_able_to :manage, :all }
    it { should be_able_to :read, :all }

    it { should be_able_to :create, Question }
    it { should be_able_to :create, Answer }
    it { should be_able_to :create, Comment }
    it { should be_able_to :create, Subscription }

    it { should be_able_to :update, own_question, user: user }
    it { should be_able_to :update, own_answer, user: user }
    it { should be_able_to :update, own_comment, user: user }
    it { should be_able_to :update, user, user: user }
    it { should_not be_able_to :update, other_question, user: user }
    it { should_not be_able_to :update, other_answer, user: user }
    it { should_not be_able_to :update, other_comment, user: user }
    it { should_not be_able_to :update, other, user: user }

    it { should be_able_to :destroy, own_question, user: user }
    it { should be_able_to :destroy, own_answer, user: user }
    it { should be_able_to :destroy, own_subscription, user: user }
    it { should be_able_to :destroy, own_comment, user: user }
    it { should_not be_able_to :destroy, other_question, user: user }
    it { should_not be_able_to :destroy, other_answer, user: user }
    it { should_not be_able_to :destroy, other_comment, user: user }
    it { should_not be_able_to :destroy, other_subscription, user: user }

    it { should be_able_to :vote_down, other_question, user: user }
    it { should be_able_to :vote_down, other_answer, user: user }
    it { should_not be_able_to :vote_down, own_question, user: user }
    it { should_not be_able_to :vote_down, own_answer, user: user }

    it { should be_able_to :vote_up, other_question, user: user }
    it { should be_able_to :vote_up, other_answer, user: user }
    it { should_not be_able_to :vote_up, own_question, user: user }
    it { should_not be_able_to :vote_up, own_answer, user: user }

    it { should be_able_to :best, other_answer, user: user }
    it { should_not be_able_to :best, other_answer2, user: user }

    it { should be_able_to :me, user, user: user }
    it { should_not be_able_to :me, other, user: user }
  end
end
