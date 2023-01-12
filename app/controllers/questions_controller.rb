# frozen_string_literal: true

class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: %i[index tagged show]
  before_action :set_question, only: %i[show update destroy]
  before_action :set_votes, only: :show
  before_action :new_answer, only: :show
  before_action :set_subscription, only: %i[show update]

  impressionist actions: [:show]

  authorize_resource

  def index
    @pagy, @questions = pagy(Question.with_votes_sum.newest.includes(:tags, :user))
  end

  def tagged
    @pagy, @questions = pagy(Question.with_votes_sum.newest.includes(:tags, :user).tagged_with(params[:tag]))
    render :index
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
