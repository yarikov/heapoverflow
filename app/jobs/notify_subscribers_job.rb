# frozen_string_literal: true

class NotifySubscribersJob < ApplicationJob
  queue_as :default

  def perform(answer)
    answer.question.subscriptions.find_each do |subscription|
      Mailer.notify(subscription.user, answer).deliver_later
    end
  end
end
