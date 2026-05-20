# frozen_string_literal: true

require 'rails_helper'

RSpec.describe CommentPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:question) { create(:question) }
  let(:record) { create(:comment, user: other, commentable: question) }
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
      let(:record) { create(:comment, user: user, commentable: question) }
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
      let(:record) { create(:comment, user: user, commentable: question) }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end
end
