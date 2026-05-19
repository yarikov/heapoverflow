# frozen_string_literal: true

module Answers
  class Create < ApplicationService
    include AfterCommitEverywhere

    def initialize(answer)
      @answer = answer
    end

    def call
      ActiveRecord::Base.transaction do
        @answer.save!
        after_commit { NotifySubscribersJob.perform_later(@answer) }
      end
      @answer
    end
  end
end
