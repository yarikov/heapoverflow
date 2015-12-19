class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :update, :destroy]
  before_action :check_author!, only: [:update, :destroy]
  before_action :new_answer, only: :show
  after_action :publish_question, only: :create

  include Voted

  respond_to :js, only: :update

  def index
    respond_with @questions = Question.all
  end

  def show
    respond_with @question
  end

  def new
    respond_with @question = Question.new
  end

  def create
    respond_with @question = current_user.questions.create(question_params)
  end

  def update
    @question.update(question_params)
    respond_with @question
  end

  def destroy
    respond_with @question.destroy
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def check_author!
    return if current_user.author_of?(@question)
    render json: { error: 'У вас нет прав на эти действия' }, status: :unprocessable_entity
  end

  def new_answer
    @answer = @question.answers.new
  end

  def publish_question
    PrivatePub.publish_to '/questions', question: @question.to_json if @question.valid?
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:id, :file, :_destroy])
  end
end
