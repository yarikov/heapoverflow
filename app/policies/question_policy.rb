# frozen_string_literal: true

class QuestionPolicy < ApplicationPolicy
  def show?
    true
  end

  alias_rule :index?, to: :show?
  alias_rule :tagged?, to: :show?

  def create?
    user.present?
  end

  alias_rule :new?, to: :create?

  def update?
    manage? || owner?
  end

  alias_rule :destroy?, to: :update?
  alias_rule :edit?, to: :update?

  def vote_up?
    user.present? && !owner?
  end

  alias_rule :vote_down?, to: :vote_up?
end
