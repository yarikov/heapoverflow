# frozen_string_literal: true

module Answers
  class Create < ApplicationService
    include AfterCommitEverywhere

    param :params
    param :author
    param :question

    def call
      answer = question.answers.new(params.merge(user: author))

      ActiveRecord::Base.transaction do
        answer.save!
        after_commit { NotifySubscribersJob.perform_later(answer) }
      end

      answer
    end
  end
end
