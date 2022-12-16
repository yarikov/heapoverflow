# frozen_string_literal: true

class SearchController < ApplicationController
  skip_authorization_check

  def search
    @resources = Searcher.call(params[:query], params[:resource], page: params[:page], per_page: 15)
    @pagy = Pagy.new_from_searchkick(@resources)
  end
end
