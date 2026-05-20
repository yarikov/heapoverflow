# frozen_string_literal: true

class QuestionPolicy < ApplicationPolicy
  def show?
    true
  end

  alias_rule :index?, to: :show?
  alias_rule :tagged?, to: :show?

  def create?
    user?
  end

  alias_rule :new?, to: :create?

  def update?
    manage? || author?
  end

  alias_rule :destroy?, to: :update?
  alias_rule :edit?, to: :update?

  def vote_up?
    user? && !author?
  end

  alias_rule :vote_down?, to: :vote_up?
end
