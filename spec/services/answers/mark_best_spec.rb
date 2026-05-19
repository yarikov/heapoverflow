# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Answers::MarkBest, type: :service do
  let(:user)     { create(:user) }
  let(:question) { create(:question, user: user) }
  let!(:answer1) { create(:answer, question: question, user: user, best: false) }
  let!(:answer2) { create(:answer, question: question, user: user, best: true) }

  describe '#call' do
    it 'marks the answer as best' do
      described_class.call(answer1)
      expect(answer1.reload.best).to eq true
    end

    it 'unmarks the previously best answer' do
      described_class.call(answer1)
      expect(answer2.reload.best).to eq false
    end

    it 'returns the answer' do
      result = described_class.call(answer1)
      expect(result).to eq(answer1)
    end

    context 'when another answer was not best' do
      let!(:answer2) { create(:answer, question: question, user: user, best: false) }

      it 'only marks the chosen answer as best' do
        described_class.call(answer1)
        expect(answer1.reload.best).to eq true
        expect(answer2.reload.best).to eq false
      end
    end
  end
end
