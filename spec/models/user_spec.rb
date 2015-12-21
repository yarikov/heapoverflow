require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:questions) }
  it { should have_many(:answers) }
  it { should have_many(:comments) }
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

  describe '#author_of?(obj)' do
    it 'returns true when user is author of object' do
      expect(author).to be_author_of question
    end

    it 'returns false when user is not author of object' do
      expect(user).not_to be_author_of question
    end
  end

  describe '#vote_up?(obj)' do
    let!(:upvote) { create(:upvote, votable: question, user: user) }

    it 'returns true if user voted up for object' do
      expect(user).to be_vote_up question
    end

    it 'returns false if user did not vote up for object' do
      expect(author).not_to be_vote_up question
    end
  end

  describe '#vote_down?(obj)' do
    let!(:downvote) { create(:downvote, votable: question, user: user) }

    it 'returns true if user voted down for object' do
      expect(user).to be_vote_down question
    end

    it 'returns false if user did not vote down for object' do
      expect(author).not_to be_vote_down question
    end
  end
end
