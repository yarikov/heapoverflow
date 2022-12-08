# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Question, type: :model do
  it { should belong_to :user }
  it { should have_many(:answers).dependent(:destroy) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }
  it { should have_many(:subscriptions).dependent(:destroy) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :title }
  it { should validate_presence_of :body }
  it { should validate_presence_of :tag_list }
  it { should validate_length_of(:title).is_at_least(10).is_at_most(200) }
  it { should validate_length_of(:body).is_at_least(10).is_at_most(3000) }

  describe '#author_subscribe' do
    let(:user)     { create(:user) }
    let(:question) { create(:question, user: user) }

    it 'subscribes author after create question' do
      expect(question.subscriptions.count).to eq 1
    end
  end
end
