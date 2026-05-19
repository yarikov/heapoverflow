# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Questions::Create, type: :service do
  let(:user) { create(:user) }

  describe '#call' do
    context 'when question is valid' do
      let(:question) do
        user.questions.build(
          title: 'Valid question title',
          body: 'Valid question body',
          tag_list: 'ruby'
        )
      end

      it 'saves the question' do
        expect { described_class.call(question, user) }.to change(Question, :count).by(1)
      end

      it 'creates author subscription' do
        described_class.call(question, user)
        expect(question.subscriptions.count).to eq(1)
        expect(question.subscriptions.first.user).to eq(user)
      end
    end

    context 'when question is invalid' do
      let(:question) do
        user.questions.build(
          title: 'short',
          body: 'short',
          tag_list: ''
        )
      end

      it 'raises ActiveRecord::RecordInvalid' do
        expect { described_class.call(question, user) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not create subscription' do
        expect { described_class.call(question, user) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(Subscription.count).to eq(0)
      end
    end
  end
end
