# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  it { should have_many(:authorizations).dependent(:destroy) }
  it { should have_many(:questions).dependent(:destroy) }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:subscriptions).dependent(:destroy) }

  it { should validate_presence_of :full_name }

  let(:author) { create(:user) }
  let(:user) { create(:user) }
  let(:question) { create(:question, user: author) }

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
