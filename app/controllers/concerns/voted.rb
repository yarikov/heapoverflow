module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, :check_user!, only: [:vote_up, :vote_down]
  end

  def vote_up
    current_user.vote_up(@votable)
    render 'votes/vote'
  end

  def vote_down
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

  def check_user!
    return unless current_user.author_of?(@votable)
    render json: { error: 'Автор не может голосовать' }, status: :unprocessable_entity
  end
end
