# frozen_string_literal: true

class DailyDigestJob < ApplicationJob
  queue_as :default

  def perform
    User.find_each do |user|
      DailyMailer.digest(user).deliver_later
    end
  end
end
