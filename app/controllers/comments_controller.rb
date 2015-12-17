class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question

  def create
    @comment = @question.comments.new(comment_params)
    @comment.user = current_user
    @comment.save
  end

  private

  def set_question
    @question = Question.find(params[:question_id])
  end

  def comment_params
    params.require(:comment).permit(:body)
  end
end
