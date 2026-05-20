# frozen_string_literal: true

class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question

  def create
    authorize! Subscription.new
    @subscription = current_user.subscriptions.find_or_create_by(question: @question)
  end

  def destroy
    subscription = current_user.subscriptions.find_by!(question: @question)
    authorize! subscription
    subscription.destroy
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
