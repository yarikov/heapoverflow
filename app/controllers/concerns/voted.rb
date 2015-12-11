module Voted
  extend ActiveSupport::Concern

  included do
    before_action :set_votable, only: [:vote_up, :vote_down]
  end

  def vote_up
    if current_user.author_of?(@votable)
      render json: { error: 'Автор не может голосовать' }, status: :unprocessable_entity
    else
      current_user.vote_up(@votable)
      render json: { id: @votable.id,
                     vote_count: @votable.vote_count,
                     vote_up: current_user.vote_up?(@votable),
                     vote_down: current_user.vote_down?(@votable) }
    end
  end

  def vote_down
    if current_user.author_of?(@votable)
      render json: { error: 'Автор не может голосовать' }, status: :unprocessable_entity
    else
      current_user.vote_down(@votable)
      render json: { id: @votable.id,
                     vote_count: @votable.vote_count,
                     vote_up: current_user.vote_up?(@votable),
                     vote_down: current_user.vote_down?(@votable) }
    end
  end

  private

  def set_votable
    @votable = model_klass.find(params[:id])
  end

  def model_klass
    controller_name.classify.constantize
  end
end
