class TagsController < ApplicationController
  skip_authorization_check

  def index
    @tags = ActsAsTaggableOn::Tag.order(name: 'asc').page(params[:page]).per(40)
  end
end
