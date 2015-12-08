module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, only: [:vote_up, :vote_down]
  end

  def vote_up
    current_user.vote_up(@votable)
    render json: @votable.vote_count
  end

  def vote_down
    current_user.vote_down(@votable)
    render json: @votable.vote_count
  end

  private

  def set_votable
    @votable = model_klass.find(params[:id])
  end

  def model_klass
    controller_name.classify.constantize
  end
end
