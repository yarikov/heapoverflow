# frozen_string_literal: true

module Questions
  class Create < ApplicationService
    def initialize(question, author)
      @question = question
      @author = author
    end

    def call
      ActiveRecord::Base.transaction do
        @question.save!
        @question.subscriptions.create!(user: @author)
      end
      @question
    end
  end
end
