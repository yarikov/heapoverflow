# frozen_string_literal: true

class UserPolicy < ApplicationPolicy
  def show?
    true
  end

  alias_rule :index?, to: :show?

  def update?
    manage? || author?
  end

  alias_rule :me?, to: :update?
  alias_rule :edit?, to: :update?

  private

  def author?
    return false unless user

    user.id == record.id
  end
end
