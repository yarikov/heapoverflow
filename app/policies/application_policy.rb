# frozen_string_literal: true

class ApplicationPolicy < ActionPolicy::Base
  authorize :user, optional: true

  default_rule :manage?

  def manage?
    user&.admin? || false
  end

  private

  def user?
    user.present?
  end

  def author?
    return false unless user

    user.author_of?(record)
  end
end
