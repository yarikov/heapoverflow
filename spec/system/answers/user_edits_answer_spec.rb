# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Edit an answer', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:answer)   { create(:answer, question: question) }

  context 'when the author of the answer' do
    let(:author) { answer.user }

    it 'updates an answer' do
      login_as(author)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        click_on 'Edit'
        fill_in 'answer[body]', with: 'Edited answer body'
        click_on 'Save'

        expect(page).to have_content 'Edited answer body'
        expect(page).to_not have_selector 'textarea'
      end
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the edit link" do
      login_as(user)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect(page).to_not have_link 'Edit'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the edit link" do
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end
