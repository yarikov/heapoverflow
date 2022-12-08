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

  describe '.find_for_oauth' do
    let!(:user) { create(:user) }
    let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345') }

    context 'user already has authorization' do
      it 'returns the user' do
        user.authorizations.create(provider: 'facebook', uid: '12345')
        expect(User.find_for_oauth(auth)).to eq user
      end
    end

    context 'user has not authorization' do
      context 'user already exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345', info: { email: user.email }) }

        it 'does not create new user' do
          expect { User.find_for_oauth(auth) }.not_to change(User, :count)
        end

        it 'creates authorization for user' do
          expect { User.find_for_oauth(auth) }.to change(user.authorizations, :count).by(1)
        end

        it 'creates authorization with provider and uid' do
          authorization = User.find_for_oauth(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it 'returns the user' do
          expect(User.find_for_oauth(auth)).to eq user
        end
      end
    end

    context 'user does not exists' do
      context 'with email' do
        let(:auth) do
          OmniAuth::AuthHash.new(
            provider: 'facebook',
            uid: '12345',
            info: { email: 'new@user.com', name: 'Petya Ivanov' }
          )
        end

        it 'creates new user' do
          expect { User.find_for_oauth(auth) }.to change(User, :count).by(1)
        end

        it 'returns new user' do
          expect(User.find_for_oauth(auth)).to be_a User
        end

        it 'fills user email' do
          user = User.find_for_oauth(auth)
          expect(user.email).to eq auth.info.email
        end

        it 'fills user full_name' do
          user = User.find_for_oauth(auth)
          expect(user.full_name).to eq auth.info.name
        end

        it 'creates authorization for user' do
          user = User.find_for_oauth(auth)
          expect(user.authorizations).to_not be_empty
        end

        it 'creates authorization with provider and uid' do
          authorization = User.find_for_oauth(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end

      context 'no email' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345', info: { email: nil }) }

        it 'does not create the user' do
          expect { User.find_for_oauth(auth) }.to_not change(User, :count)
        end

        it 'returns new user' do
          expect(User.find_for_oauth(auth)).to be_a_new User
        end

        it 'does not create authorization' do
          expect { User.find_for_oauth(auth) }.to_not change(Authorization, :count)
        end
      end
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
