class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: [:update, :destroy, :best]
  before_action :set_question, only: [:create, :update, :best]
  after_action :broadcast_answer, only: :create

  include Voted

  respond_to :js

  authorize_resource

  def create
    respond_with @answer = @question.answers.create(answer_params.merge(user: current_user))
  end

  def update
    @answer.update(answer_params)
    respond_with @answer
  end

  def best
    respond_with @answer.best!
  end

  def destroy
    respond_with @answer.destroy
  end

  private

  def set_answer
    @answer = Answer.find(params[:id])
  end

  def set_question
    @question = @answer.question if @answer
    @question ||= Question.find(params[:question_id])
  end

  def broadcast_answer
    return unless @answer.valid?

    ActionCable.server.broadcast("/questions/#{@question.id}/answers",
      {
        answer: @answer.to_json,
        vote_count: @answer.vote_count.to_json
      }
    )
  end

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:id, :file, :_destroy])
  end
end
