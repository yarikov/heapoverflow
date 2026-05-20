# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, optional: true

  default_rule :manage?

  def manage?
    user&.admin? || false
  end

  private

  def owner?
    return false unless user

    user.id == record.user_id
  end
end
