# frozen_string_literal: true

class SearchController < ApplicationController
  def search
    @pagy, @resources = pagy(:searchkick, Searchkick.pagy_search(params[:query], models: [Question, Answer]), limit: 15)
  end
end
