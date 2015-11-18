require 'rails_helper'

feature 'Сreate a question', '
  In order to get answers
  As an user
  I want to ask a question
' do
  scenario 'Authenticated user creates a question' do
    User.create!(email: 'user@test.com', password: '12345678')

    visit new_user_session_path
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    click_on 'Log in'

    visit questions_path
    click_on 'Задать вопрос'
    fill_in 'Суть вопроса', with: 'Question title'
    fill_in 'Детали вопроса', with: 'Question body'
    click_on 'Опубликовать'

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Question body'
  end

  scenario 'Unauthenticated user creates a question' do
    visit questions_path
    click_on 'Задать вопрос'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
