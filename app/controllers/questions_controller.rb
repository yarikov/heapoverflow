class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index show]
  before_action :set_question, only: %i[show update destroy]
  before_action :new_answer, only: :show
  before_action :set_subscription, only: %i[show update]
  after_action :broadcast_question, only: :create

  impressionist actions: [:show]

  authorize_resource

  def index
    respond_with @questions = Question.newest.page(params[:page]).per(15)
  end

  def show
    respond_with @question
  end

  def new
    respond_with @question = Question.new
  end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      redirect_to question_url(@question)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @question.update(question_params)
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    respond_with @question.destroy
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def set_subscription
    @subscription = @question.subscriptions.find_by(user: current_user)
  end

  def new_answer
    @answer = @question.answers.new
  end

  def broadcast_question
    ActionCable.server.broadcast('/questions', { question: @question.to_json }) if @question.valid?
  end

  def question_params
    params.require(:question)
          .permit(:title, :body, :tag_list)
  end
end
