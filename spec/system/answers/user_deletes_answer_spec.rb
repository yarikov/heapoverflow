# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Delete an answer', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:answer)   { create(:answer, question: question) }

  context 'when the author of the answer' do
    let(:author) { answer.user }

    it 'deletes an answer' do
      login_as(author)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect { accept_confirm { click_on('Delete') } }.to change(author.answers, :count).by(-1)
      end

      expect(page).to_not have_content(answer.body)
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the delete link" do
      login_as(user)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect(page).to_not have_link 'Delete'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the delete link" do
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect(page).to_not have_link 'Delete'
      end
    end
  end
end
