require 'rails_helper'

feature 'Сreate an answer', '
  In order to resolve the issue
  As an user
  I want to answer the question
' do
  given!(:question) { create(:question) }

  scenario 'User answers the question' do
    visit question_path(question)
    click_on 'Ответить'
    fill_in 'Ваш ответ на вопрос', with: 'Answer body'
    click_on 'Ответить'

    expect(page).to have_content 'Answer body'
  end
end
