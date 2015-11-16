class AnswersController < ApplicationController
  before_action :set_question

  def new
    @answer = Answer.new
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end
end
