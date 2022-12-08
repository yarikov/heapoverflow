# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searcher, type: :model do
  describe '.call' do
    context 'when query is nil' do
      it 'does not search' do
        described_class.call(nil, 'Answer')
        expect(Searchkick).to_not receive(:search)
      end

      it 'returns an empty array' do
        expect(described_class.call(nil, 'Answer')).to eq []
      end
    end

    %w[User Question Answer Comment].each do |resource|
      it "searches in #{resource}" do
        expect(Searchkick).to receive(:search).with('something', { models: [resource.constantize] })
        described_class.call('something', resource)
      end
    end

    it 'searches in all models' do
      expect(Searchkick).to receive(:search).with('something', { models: Searcher::MODELS.map(&:constantize) })
      described_class.call('something', 'All')
    end
  end
end
