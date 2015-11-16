class AnswersController < ApplicationController
  before_action :set_question

  def new
    @answer = Answer.new
  end

  def create
    @answer = @question.answers.new(answer_params)

    if @question.save
      redirect_to @question
    else
      render :new
    end
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
