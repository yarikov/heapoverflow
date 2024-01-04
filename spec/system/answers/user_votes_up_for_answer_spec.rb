# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Vote up for an answer', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:answer)   { create(:answer, question: question) }

  context 'when the authenticated user' do
    let(:user) { create(:user) }

    it 'changes vote count' do
      login_as(user)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '1'
        expect(page).to have_selector '.voting__up-btn--active'

        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__up-btn--active'
      end
    end
  end

  context 'when the author' do
    let(:author) { answer.user }

    it "doesn't change vote count" do
      login_as(author)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__up-btn--active'
      end
    end
  end

  context 'when the guest' do
    it 'redirects to the login page' do
      visit question_path(question)

      within ".answer-#{answer.id}" do
        find('.voting__up-btn').click
        expect(page).to have_current_path(new_user_session_path)
      end
    end
  end
end
