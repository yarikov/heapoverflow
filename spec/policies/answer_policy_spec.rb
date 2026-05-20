# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AnswerPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:question) { create(:question) }
  let(:other_question) { create(:question, user: other) }
  let(:record) { create(:answer, question: question, user: other) }
  let(:context) { { user: user } }

  describe_rule :show? do
    succeed 'for guest' do
      let(:user) { nil }
    end

    succeed 'for user'
  end

  describe_rule :create? do
    succeed 'for user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :update? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for author' do
      let(:record) { create(:answer, question: question, user: user) }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :destroy? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for author' do
      let(:record) { create(:answer, question: question, user: user) }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :best? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for question author' do
      let(:question) { create(:question, user: user) }
      let(:record) { create(:answer, question: question, user: other) }
    end

    failed 'for other user' do
      let(:record) { create(:answer, question: other_question, user: other) }
    end

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :vote_up? do
    succeed 'for user on other answer'

    failed 'for user on own answer' do
      let(:record) { create(:answer, question: question, user: user) }
    end

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :vote_down? do
    succeed 'for user on other answer'

    failed 'for user on own answer' do
      let(:record) { create(:answer, question: question, user: user) }
    end

    failed 'for guest' do
      let(:user) { nil }
    end
  end
end
