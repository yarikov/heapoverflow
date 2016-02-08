class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_comment, only: [:update, :destroy]
  before_action :set_commentable, only: :create
  after_action :publish_comment, only: :create

  respond_to :js, only: :create
  respond_to :json, only: [:update, :destroy]

  authorize_resource

  def create
    respond_with @comment = @commentable.comments.create(comment_params.merge(user: current_user))
  end

  def update
    @comment.update(comment_params)
    respond_with @comment do |format|
      format.json { render json: @comment }
    end
  end

  def destroy
    respond_with @comment.destroy
  end

  private

  def set_comment
    @comment = Comment.find(params[:id])
  end

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
