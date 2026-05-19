# frozen_string_literal: true

class TagsController < ApplicationController
  skip_authorization_check

  def index
    @pagy, @tags = pagy(:offset, ActsAsTaggableOn::Tag.order(name: 'asc'), limit: 60)
  end
end
