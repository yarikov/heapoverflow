class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:update, :destroy]
  before_action :set_commentable, only: :create
  after_action :broadcast_comment, only: :create

  authorize_resource

  def create
    @comment = @commentable.comments.new(comment_params.merge(user: current_user))

    if @comment.save
      render :create
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @comment.update(comment_params)
      render :update
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def set_commentable
    return @commentable = Question.find(params[:question_id]) if params[:question_id]
    @commentable = Answer.find(params[:answer_id]) if params[:answer_id]
  end

  def broadcast_comment
    ActionCable.server.broadcast(comment_path, { comment: @comment.to_json }) if @comment.valid?
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
