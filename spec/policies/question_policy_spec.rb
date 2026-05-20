# frozen_string_literal: true

require 'rails_helper'

RSpec.describe QuestionPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:record) { create(:question, user: other) }
  let(:context) { { user: user } }

  describe_rule :show? do
    succeed 'for guest' do
      let(:user) { nil }
    end

    succeed 'for user'
  end

  describe_rule :tagged? do
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

    succeed 'for owner' do
      let(:record) { create(:question, user: user) }
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

    succeed 'for owner' do
      let(:record) { create(:question, user: user) }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :vote_up? do
    succeed 'for user on other question'

    failed 'for user on own question' do
      let(:record) { create(:question, user: user) }
    end

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :vote_down? do
    succeed 'for user on other question'

    failed 'for user on own question' do
      let(:record) { create(:question, user: user) }
    end

    failed 'for guest' do
      let(:user) { nil }
    end
  end
end
