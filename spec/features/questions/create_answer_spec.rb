require 'rails_helper'

feature 'Сreate an answer', '
  In order to resolve the issue
  As an user
  I want to answer the question
' do
  given(:user) { create(:user) }
  given!(:question) { create(:question) }

  scenario 'Authenticated user creates an answer' do
    sign_in(user)

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
