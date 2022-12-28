# frozen_string_literal: true

class SearchController < ApplicationController
  skip_authorization_check

  def search
    @resources = Searchkick.search(params[:query], models: [Question, Answer], page: params[:page], per_page: 15)
    @pagy = Pagy.new_from_searchkick(@resources)
  end
end
