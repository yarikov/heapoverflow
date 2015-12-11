require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions) }
  it { should have_many(:answers) }
  it { should have_many(:votes).dependent(:destroy) }

  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:question) { create(:question, user: author) }

  describe '#vote_up' do
    it 'deletes upvote if user voted up' do
      user.vote_up(question)
      user.vote_up(question)
      expect(question.vote_count).to eq 0
    end

    it 'changes downvote to upvote if user voted down' do
      user.vote_down(question)
      user.vote_up(question)
      expect(question.vote_count).to eq 1
    end

    it 'create upvote if user did not vote' do
      user.vote_up(question)
      expect(question.vote_count).to eq 1
    end
  end

  describe '#vote_down' do
    it 'deletes downvote if user voted down' do
      user.vote_down(question)
      user.vote_down(question)
      expect(question.vote_count).to eq 0
    end

    it 'changes upvote to downvote if user voted up' do
      user.vote_up(question)
      user.vote_down(question)
      expect(question.vote_count).to eq(-1)
    end

    it 'create downvote if user did not vote' do
      user.vote_down(question)
      expect(question.vote_count).to eq(-1)
    end
  end
end
