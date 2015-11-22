require_relative '../feature_helper'

feature 'Сreate an answer', '
  In order to resolve the issue
  As an user
  I want to answer the question
' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }

  scenario 'Authenticated user creates an answer', js: true do
    sign_in(user)

    visit question_path(question)
    fill_in 'Ваш ответ на вопрос', with: 'Answer body'
    click_on 'Ответить'

    expect(current_path).to eq question_path(question)
    within('.answers') { expect(page).to have_content 'Answer body' }
  end

  scenario 'Authenticated user creates invalid answer', js: true do
    sign_in(user)
    visit question_path(question)

    click_on 'Ответить'

    expect(page).to have_content "Body can't be blank"
  end

  scenario 'Unauthenticated user creates an answer' do
    visit question_path(question)
    expect(page).to_not have_button('Ответить')
  end
end
