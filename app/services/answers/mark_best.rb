# frozen_string_literal: true

module Answers
  class MarkBest < ApplicationService
    def initialize(answer)
      @answer = answer
    end

    def call
      ActiveRecord::Base.transaction do
        @answer.question.answers.where(best: true).update(best: false)
        @answer.update(best: true)
      end
      @answer
    end
  end
end
