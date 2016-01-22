require 'rails_helper'

RSpec.describe Mailer, type: :mailer do
  describe 'notify' do
    let(:user)     { create(:user) }
    let(:question) { create(:question, user: user) }
    let(:answer)   { create(:answer, question: question, user: user) }
    let(:mail)     { Mailer.notify(user, answer) }

    it 'renders the headers' do
      expect(mail.subject).to eq('Notify')
      expect(mail.to).to eq [user.email]
      expect(mail.from).to eq(['from@example.com'])
    end

    it 'renders questions created last 24 hours' do
      expect(mail.body.encoded).to match(answer.body)
    end
  end
end
