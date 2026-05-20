# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:user) { create(:user) }
  let(:record) { create(:user) }
  let(:context) { { user: user } }

  describe_rule :show? do
    succeed 'for guest' do
      let(:user) { nil }
    end

    succeed 'for user'

    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end
  end

  describe_rule :update? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for owner' do
      let(:record) { user }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end

  describe_rule :me? do
    succeed 'for admin' do
      let(:user) { create(:user, admin: true) }
    end

    succeed 'for owner' do
      let(:record) { user }
    end

    failed 'for other user'

    failed 'for guest' do
      let(:user) { nil }
    end
  end
end
