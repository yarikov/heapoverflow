require 'rails_helper'

feature 'Сreate an answer', '
  In order to resolve the issue
  As an user
  I want to answer the question
' do
  given!(:question) { create(:question) }

  scenario 'Authenticated user creates an answer' do
    User.create!(email: 'user@test.com', password: '12345678')

    visit new_user_session_path
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    click_on 'Log in'

    visit question_path(question)
    click_on 'Ответить'
    fill_in 'Ваш ответ на вопрос', with: 'Answer body'
    click_on 'Ответить'

    expect(page).to have_content 'Answer body'
  end

  scenario 'Unauthenticated user creates an answer' do
    visit question_path(question)
    click_on 'Ответить'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
