require_relative '../feature_helper'

feature 'Subscribe to question' do
  given(:user)                { create(:user) }
  given(:question)            { create(:question) }
  given(:subscribed_question) { create(:question, user: user) }

  context 'User' do
    before do
      sign_in(user)
    end

    scenario 'can subscribe to question', js: true do
      visit question_path(question)

      click_on 'Subscribe'

      expect(page).to_not have_link 'Subscribe'
      expect(page).to have_link 'Unsubscribe'
    end

    scenario 'can unsubscribe from question', js: true do
      visit question_path(subscribed_question)

      click_on 'Unsubscribe'

      expect(page).to_not have_link 'Unsubscribe'
      expect(page).to have_link 'Subscribe'
    end
  end
end
