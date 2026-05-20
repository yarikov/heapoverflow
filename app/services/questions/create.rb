# frozen_string_literal: true

module Questions
  class Create < ApplicationService
    param :params
    param :author

    def call
      question = author.questions.new(params)

      ActiveRecord::Base.transaction do
        question.save!
        question.subscriptions.create!(user: author)
      end

      question
    end
  end
end
