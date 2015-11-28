require 'rails_helper'

RSpec.describe Answer, type: :model do
  it { should belong_to :user }
  it { should belong_to :question }
  it { should have_many :attachments }

  it { should validate_presence_of :user_id }
  it { should validate_presence_of :question_id }
  it { should validate_presence_of :body }

  it { should accept_nested_attributes_for :attachments }

  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }
  let!(:answer1) { create(:answer, question: question, user: user, best: false) }
  let!(:answer2) { create(:answer, question: question, user: user, best: true) }

  it 'should choose the best answer' do
    answer1.best!
    answer2.reload

    expect(answer1.best).to eq true
    expect(answer2.best).to eq false
  end
end
