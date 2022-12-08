# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Add cooment to question' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }

  scenario 'Authenticated user add comment to question', js: true do
    login_as(user)
    visit question_path(question)

    click_on 'Добавить комментарий'
    fill_in 'Комментарий', with: 'Comment body'
    click_on 'Сохранить'

    expect(page).to have_content 'Comment body'
  end

  scenario 'Unauthenticated user does not see link' do
    visit question_path(question)

    expect(page).to_not have_link 'Добавить комментарий'
  end
end
