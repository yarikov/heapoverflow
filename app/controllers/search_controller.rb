# frozen_string_literal: true

class SearchController < ApplicationController
  skip_authorization_check

  def search
    @pagy, @resources = pagy(:searchkick, Searchkick.pagy_search(params[:query], models: [Question, Answer]), limit: 15)
  end
end
