class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: [:update, :destroy, :best]
  before_action :set_question, only: [:new, :create]

  def create
    @answer = @question.answers.new(answer_params)
    @answer.user = current_user
    @answer.save
  end

  def update
    if current_user.author_of?(@answer)
      @answer.update(answer_params)
      @question = @answer.question
      flash.now[:notice] = 'Ответ на вопрос успешно отредактирован'
    else
      flash.now[:alert] = 'У вас нет прав на эти действия'
    end
  end

  def best
    if current_user.author_of?(@answer.question)
      @answer.best!
      flash.now[:notice] = 'Вы выбрали лучший ответ'
    else
      flash.now[:alert] = 'У вас нет прав на эти действия'
    end
  end

  def destroy
    if current_user.author_of?(@answer)
      @answer.destroy
      flash.now[:notice] = 'Ответ на вопрос успешно удален'
    else
      flash.now[:alert] = 'У вас нет прав на эти действия'
    end
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:file])
  end
end
