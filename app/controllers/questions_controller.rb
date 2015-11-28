class QuestionsController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :set_question, only: [:show, :update, :destroy]

  def index
    @questions = Question.all
  end

  def show
    @answer = @question.answers.new
    @answer.attachments.new
  end

  def new
    @question = Question.new
    @question.attachments.new
  end

  def create
    @question = current_user.questions.new(question_params)

    if @question.save
      redirect_to @question
    else
      render :new
    end
  end

  def update
    if current_user.author_of?(@question)
      @question.update(question_params)
      flash.now[:notice] = 'Вопрос успешно отредактирован'
    else
      flash.now[:alert] = 'У вас нет прав на эти действия'
    end
  end

  def destroy
    if current_user.author_of?(@question)
      @question.destroy
      redirect_to questions_path, notice: 'Вопрос успешно удален'
    else
      redirect_to @question, alert: 'У вас нет прав на эти действия'
    end
  end

  private

  def set_question
    @question = Question.find(params[:id])
  end

  def question_params
    params.require(:question).permit(:title, :body, attachments_attributes: [:file])
  end
end
