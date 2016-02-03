class TagsController < ApplicationController
  skip_authorization_check

  def index
    @tags = ActsAsTaggableOn::Tag.all
  end

  def show
    @questions = Question.tagged_with(params[:id]).page(params[:page]).per(15)
    render 'questions/index'
  end
end
