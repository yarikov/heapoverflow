# frozen_string_literal: true

class TagsController < ApplicationController
  skip_authorization_check

  def index
    @pagy, @tags = pagy(ActsAsTaggableOn::Tag.order(name: 'asc'), items: 60)
  end
end
