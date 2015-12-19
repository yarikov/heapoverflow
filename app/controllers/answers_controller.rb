class AnswersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_answer, only: [:update, :destroy, :best]
  before_action :set_question, only: [:create, :update]
  before_action :check_answer_author!, only: [:update, :destroy]
  before_action :check_question_author!, only: :best
  after_action :publish_answer, only: :create

  include Voted

  respond_to :js

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

  def check_answer_author!
    return if current_user.author_of?(@answer)
    render json: { error: 'У вас нет прав на эти действия' }, status: :unprocessable_entity
  end

  def check_question_author!
    return if current_user.author_of?(@answer.question)
    render json: { error: 'У вас нет прав на эти действия' }, status: :unprocessable_entity
  end

  def publish_answer
    PrivatePub.publish_to "/questions/#{@question.id}/answers",
                          answer: @answer.to_json,
                          vote_count: @answer.vote_count.to_json if @answer.valid?
  end

  def answer_params
    params.require(:answer).permit(:body, attachments_attributes: [:id, :file, :_destroy])
  end
end
