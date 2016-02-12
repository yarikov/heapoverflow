require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :user }
  it { should belong_to :question }
  it { should have_many(:attachments).dependent(:destroy) }
  it { should have_many(:votes).dependent(:destroy) }
  it { should have_many(:comments).dependent(:destroy) }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :question_id }
  it { should validate_presence_of :body }
  it { should validate_length_of(:body).is_at_least(10).is_at_most(3000) }

  it { should accept_nested_attributes_for :attachments }

  describe '#best!' do
    let(:user)     { create(:user) }
    let(:question) { create(:question, user: user) }
    let!(:answer1) { create(:answer, question: question, user: user, best: false) }
    let!(:answer2) { create(:answer, question: question, user: user, best: true) }

    before { answer1.best! }

    it 'should choose the best answer' do
      expect(answer1.best).to eq true
    end

    it 'changes another answer to false' do
      expect(answer2.reload.best).to eq false
    end
  end
end
