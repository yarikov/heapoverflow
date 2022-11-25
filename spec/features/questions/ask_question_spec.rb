require_relative '../feature_helper'

feature 'Ask question' do
  given(:user) { create(:user) }

  scenario 'when authenticated user', js: true do
    login_as(user)
    visit new_question_path

    fill_in 'Title', with: 'Question title'
    fill_in 'Body', with: 'Question body'
    fill_in 'Tags', with: 'ruby-on-rails'
    click_on 'Post Your Question'

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Question body'
    expect(page).to have_content 'ruby-on-rails'
  end

  scenario 'when unauthenticated user' do
    visit questions_path
    click_on 'Ask Question'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
