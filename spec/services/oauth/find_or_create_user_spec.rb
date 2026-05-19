# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Oauth::FindOrCreateUser, type: :service do
  let!(:user) { create(:user) }
  let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345') }

  describe '#call' do
    context 'user already has authorization' do
      it 'returns the user' do
        user.authorizations.create(provider: 'facebook', uid: '12345')
        expect(described_class.call(auth)).to eq user
      end
    end

    context 'user has not authorization' do
      context 'user already exists' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345', info: { email: user.email }) }

        it 'does not create new user' do
          expect { described_class.call(auth) }.not_to change(User, :count)
        end

        it 'creates authorization for user' do
          expect { described_class.call(auth) }.to change(user.authorizations, :count).by(1)
        end

        it 'creates authorization with provider and uid' do
          authorization = described_class.call(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end

        it 'returns the user' do
          expect(described_class.call(auth)).to eq user
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
          expect { described_class.call(auth) }.to change(User, :count).by(1)
        end

        it 'returns new user' do
          expect(described_class.call(auth)).to be_a User
        end

        it 'fills user email' do
          user = described_class.call(auth)
          expect(user.email).to eq auth.info.email
        end

        it 'fills user full_name' do
          user = described_class.call(auth)
          expect(user.full_name).to eq auth.info.name
        end

        it 'creates authorization for user' do
          user = described_class.call(auth)
          expect(user.authorizations).to_not be_empty
        end

        it 'creates authorization with provider and uid' do
          authorization = described_class.call(auth).authorizations.first

          expect(authorization.provider).to eq auth.provider
          expect(authorization.uid).to eq auth.uid
        end
      end

      context 'no email' do
        let(:auth) { OmniAuth::AuthHash.new(provider: 'facebook', uid: '12345', info: { email: nil }) }

        it 'does not create the user' do
          expect { described_class.call(auth) }.to_not change(User, :count)
        end

        it 'returns new user' do
          expect(described_class.call(auth)).to be_a_new User
        end

        it 'does not create authorization' do
          expect { described_class.call(auth) }.to_not change(Authorization, :count)
        end
      end
    end
  end
end
