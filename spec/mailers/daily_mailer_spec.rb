require 'rails_helper'

RSpec.describe DailyMailer, type: :mailer do
  describe 'digest' do
    let(:user)          { create(:user) }
    let(:questions)     { create_list(:question, 2, user: user) }
    let(:old_questions) { create_list(:question, 2, user: user, created_at: 2.days.ago) }
    let(:mail)          { DailyMailer.digest(user) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Digest')
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders questions created last 24 hours' do
      questions.each do |question|
        expect(mail.body.encoded).to match(question.title)
      end
    end

    it 'does not render questions created earlier than last 24 hours' do
      old_questions.each do |question|
        expect(mail.body.encoded).to_not match(question.title)
      end
    end
  end
end
