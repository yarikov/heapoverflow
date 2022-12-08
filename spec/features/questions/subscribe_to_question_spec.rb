# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Subscribe to question' do
  given(:user)                { create(:user) }
  given(:question)            { create(:question) }
  given(:subscribed_question) { create(:question, user: user) }

  context 'User' do
    before do
      login_as(user)
    end

    scenario 'can subscribe to question', js: true do
      visit question_path(question)

      find('.subscribe').click

      within '.subscription' do
        expect(page).to have_css '.unsubscribe'
        expect(page).to have_content '2'
      end
    end

    scenario 'can unsubscribe from question', js: true do
      visit question_path(subscribed_question)

      find('.unsubscribe').click

      within '.subscription' do
        expect(page).to have_css '.subscribe'
        expect(page).to have_content '0'
      end
    end
  end
end
