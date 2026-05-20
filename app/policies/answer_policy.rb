# frozen_string_literal: true

class AnswerPolicy < ApplicationPolicy
  def show?
    true
  end

  alias_rule :index?, to: :show?

  def create?
    user?
  end

  alias_rule :new?, to: :create?

  def update?
    manage? || author?
  end

  alias_rule :destroy?, to: :update?
  alias_rule :edit?, to: :update?

  def best?
    manage? || user&.author_of?(record.question)
  end

  def vote_up?
    user? && !author?
  end

  alias_rule :vote_down?, to: :vote_up?
end
