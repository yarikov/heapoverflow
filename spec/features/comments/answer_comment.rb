# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Add cooment to answer' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: user) }

  scenario 'Authenticated user add comment to answer', js: true do
    login_as(user)
    visit question_path(question)

    within '.answers' do
      click_on 'Добавить комментарий'
      fill_in 'Комментарий', with: 'Comment body'
      click_on 'Сохранить'

      expect(page).to have_content 'Comment body'
    end
  end

  scenario 'Unauthenticated user does not see link' do
    visit question_path(question)

    within '.answers' do
      expect(page).to_not have_link 'Добавить комментарий'
    end
  end
end
