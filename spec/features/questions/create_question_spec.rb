require_relative '../feature_helper'

feature 'Сreate a question', '
  In order to get answers
  As an user
  I want to ask a question
' do
  given(:user) { create(:user) }

  scenario 'Authenticated user creates a question' do
    sign_in(user)
    visit new_question_path

    fill_in 'Суть вопроса', with: 'Question title'
    fill_in 'Детали вопроса', with: 'Question body'
    attach_file 'Файл', "#{Rails.root}/spec/spec_helper.rb"
    click_on 'Опубликовать'

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Question body'
    expect(page).to have_link 'spec_helper.rb', href: '/uploads/attachment/file/1/spec_helper.rb'
  end

  scenario 'Unauthenticated user creates a question' do
    visit questions_path
    click_on 'Задать вопрос'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end
