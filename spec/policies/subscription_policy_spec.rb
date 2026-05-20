# frozen_string_literal: true

require 'rails_helper'

RSpec.describe SubscriptionPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:other) { create(:user) }
  let(:question) { create(:question) }
  let(:record) { create(:subscription, user: other, question: question) }
  let(:context) { { user: user } }

  describe_rule :create? do
    succeed 'for user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :destroy? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for author' do
      let(:record) { create(:subscription, user: user, question: question) }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end
end
