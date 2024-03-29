# frozen_string_literal: true

class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: %i[update destroy best]
  before_action :set_question, only: %i[create update best]

  authorize_resource

  def create
    @answer = @question.answers.new(answer_params.merge(user: current_user))

    if @answer.save
      render :create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @answer.update(answer_params)
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def best
    @answer.best!
    @answer.reload
  end

  def destroy
    @answer.destroy
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = @answer.question if @answer
    @question ||= Question.find(params[:question_id])
  end

  def answer_params
    params.require(:answer).permit(:body)
  end
end
