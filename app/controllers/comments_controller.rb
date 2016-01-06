class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  after_action :publish_comment

  respond_to :js

  authorize_resource

  def create
    respond_with @comment = @commentable.comments.create(comment_params.merge(user: current_user))
  end

  private

  def set_commentable
    return @commentable = Question.find(params[:question_id]) if params[:question_id]
    @commentable = Answer.find(params[:answer_id]) if params[:answer_id]
  end

  def publish_comment
    PrivatePub.publish_to comment_path, comment: @comment.to_json if @comment.valid?
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
