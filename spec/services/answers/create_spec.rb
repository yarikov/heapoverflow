# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Answers::Create, type: :service do
  let(:user)     { create(:user) }
  let(:question) { create(:question, user: user) }

  describe '#call' do
    context 'when answer is valid' do
      let(:answer) { question.answers.build(body: 'Valid answer body', user: user) }

      it 'saves the answer' do
        expect { described_class.call(answer) }.to change(Answer, :count).by(1)
      end

      it 'enqueues NotifySubscribersJob after commit' do
        allow(NotifySubscribersJob).to receive(:perform_later)
        described_class.call(answer)
        expect(NotifySubscribersJob).to have_received(:perform_later).with(answer)
      end
    end

    context 'when answer is invalid' do
      let(:answer) { question.answers.build(body: 'short', user: user) }

      it 'raises ActiveRecord::RecordInvalid' do
        expect { described_class.call(answer) }.to raise_error(ActiveRecord::RecordInvalid)
      end

      it 'does not enqueue NotifySubscribersJob' do
        allow(NotifySubscribersJob).to receive(:perform_later)
        expect { described_class.call(answer) }.to raise_error(ActiveRecord::RecordInvalid)
        expect(NotifySubscribersJob).not_to have_received(:perform_later)
      end
    end
  end
end
