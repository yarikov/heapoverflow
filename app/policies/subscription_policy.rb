# frozen_string_literal: true

class SubscriptionPolicy < ApplicationPolicy
  def create?
    user?
  end

  alias_rule :new?, to: :create?

  def destroy?
    manage? || author?
  end
end
