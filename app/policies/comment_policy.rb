# frozen_string_literal: true

class CommentPolicy < ApplicationPolicy
  def show?
    true
  end

  alias_rule :index?, to: :show?

  def create?
    user.present?
  end

  alias_rule :new?, to: :create?

  def update?
    manage? || owner?
  end

  alias_rule :destroy?, to: :update?
  alias_rule :edit?, to: :update?
end
