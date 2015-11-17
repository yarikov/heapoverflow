require 'rails_helper'

feature 'Сreate a question', '
  In order to get answers
  As an user
  I want to ask a question
' do
  scenario 'User creates a question' do
    visit questions_path
    click_on 'Задать вопрос'
    fill_in 'Суть вопроса', with: 'Question title'
    fill_in 'Детали вопроса', with: 'Question body'
    click_on 'Опубликовать'

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Question body'
  end
end
