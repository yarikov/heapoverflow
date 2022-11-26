class VotesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_votable

  def up
    authorize! :vote_up, @votable
    @vote = current_user.votes.find_or_initialize_by(votable: @votable)
    @vote.update(value: 1)
    render 'votes/vote'
  end

  def down
    authorize! :vote_down, @votable
    @vote = current_user.votes.find_or_initialize_by(votable: @votable)
    @vote.update(value: -1)
    render 'votes/vote'
  end

  def destroy
    authorize! :vote_down, @votable
    @vote = current_user.votes.destroy_by(votable: @votable)
    render 'votes/vote'
  end

  private

  def set_votable
    @votable =
      if params[:question_id]
        Question.find(params[:question_id])
      elsif params[:answer_id]
        Answer.find(params[:answer_id])
      else
        raise ActiveRecord::RecordNotFound
      end
  end
end
