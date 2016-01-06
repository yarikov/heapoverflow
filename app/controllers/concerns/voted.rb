module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, only: [:vote_up, :vote_down]
  end

  def vote_up
    authorize! :vote_up, @votable
    current_user.vote_up(@votable)
    render 'votes/vote'
  end

  def vote_down
    authorize! :vote_down, @votable
    current_user.vote_down(@votable)
    render 'votes/vote'
  end

  private

  def set_votable
    @votable = model_klass.find(params[:id])
  end

  def model_klass
    controller_name.classify.constantize
  end
end
