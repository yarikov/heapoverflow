# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Searcher, type: :model do
  describe '.call' do
    %w[Question Answer].each do |resource|
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
