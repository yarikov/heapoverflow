class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question
  authorize_resource

  def create
    @subscription = current_user.subscriptions.find_or_create_by(question: @question)
  end

  def destroy
    @subscription = current_user.subscriptions.destroy_by(question: @question)
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
