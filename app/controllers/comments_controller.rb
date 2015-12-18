class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_question

  def create
    @comment = @commentable.comments.new(comment_params)
    @comment.user = current_user
    PrivatePub.publish_to comment_path, comment: @comment.to_json if @comment.save
  end

  private

  def set_question
    return @commentable = Question.find(params[:question_id]) if params[:question_id]
    @commentable = Answer.find(params[:answer_id]) if params[:answer_id]
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def comment_path
    if @comment.commentable_type == 'Question'
      "/questions/#{@commentable.id}/comments"
    else
      "/questions/#{@commentable.question_id}/comments"
    end
  end
end
