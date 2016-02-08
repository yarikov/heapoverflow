class SubscriptionsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question
  authorize_resource

  respond_to :js

  def create
    respond_with @subscription = current_user.subscriptions.create(question: @question)
  end

  def destroy
    @subscription = current_user.subscriptions.find(params[:id])
    respond_with @subscription.destroy
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
