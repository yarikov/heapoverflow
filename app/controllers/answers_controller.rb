class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question, only: [:new, :create]

  def new
    @answer = Answer.new
  end

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user

    if @answer.save
      redirect_to @question
    else
      render :new
    end
  end

  def destroy
    @answer = Answer.find(params[:id])
    @answer.destroy if @answer.user_id == current_user.id
    redirect_to @answer.question, notice: 'Ответ на вопрос успешно удален'
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
