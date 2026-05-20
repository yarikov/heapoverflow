# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index tagged show]
  before_action :set_question, only: %i[show update destroy]
  before_action :set_votes, only: :show
  before_action :new_answer, only: :show
  before_action :set_subscription, only: %i[show update]

  impressionist actions: [:show]

  def index
    authorize! Question.new
    @pagy, @questions = pagy(:offset, Question.with_votes_sum.newest.includes(:tags, :user))
  end

  def tagged
    authorize! Question.new, to: :tagged?
    @pagy, @questions = pagy(:offset, Question.with_votes_sum.newest.includes(:tags, :user).tagged_with(params[:tag]))
    render :index
  end

  def show
    authorize! @question
    respond_with @question
  end

  def new
    authorize! Question.new
    respond_with @question = Question.new
  end

  def create
    authorize! Question.new
    @question = Questions::Create.call(question_params, current_user)
    redirect_to question_url(@question)
  rescue ActiveRecord::RecordInvalid => e
    @question = e.record
    render :new, status: :unprocessable_entity
  end

  def update
    authorize! @question
    if @question.update(question_params)
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize! @question
    respond_with @question.destroy
  end

  private

  def set_question
    @question = Question.with_votes_sum.includes(comments: :user).find(params[:id])
  end

  def set_votes
    @votes = Vote.where(user: current_user, votable: [@question] + @question.answers)
  end

  def set_subscription
    @subscription = @question.subscriptions.find_by(user: current_user)
  end

  def new_answer
    @answer = @question.answers.new
  end

  def question_params
    params.require(:question)
          .permit(:title, :body, :tag_list)
  end
end
