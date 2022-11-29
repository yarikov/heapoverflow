class TagsController < ApplicationController
  skip_authorization_check

  def index
    @tags = ActsAsTaggableOn::Tag.all
  end
end
