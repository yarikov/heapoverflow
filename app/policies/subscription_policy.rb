# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def create?
    user.present?
  end

  alias_rule :new?, to: :create?

  def destroy?
    manage? || owner?
  end
end
