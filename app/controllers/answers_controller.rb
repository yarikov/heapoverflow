# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: %i[update destroy best]
  before_action :set_question, only: %i[create update best]

  def create
    authorize! Answer.new
    @answer = Answers::Create.call(answer_params, current_user, @question)
    render :create
  rescue ActiveRecord::RecordInvalid => e
    @answer = e.record
    render :new, status: :unprocessable_entity
  end

  def update
    authorize! @answer
    if @answer.update(answer_params)
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def best
    authorize! @answer
    Answers::MarkBest.call(@answer)
    @answer.reload
  end

  def destroy
    authorize! @answer
    @answer.destroy
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = if @answer
                  @answer.question
                else
                  Question.find(params[:question_id])
                end
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
