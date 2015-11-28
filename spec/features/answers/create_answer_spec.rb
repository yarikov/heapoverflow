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
    attach_file 'Файл', "#{Rails.root}/spec/spec_helper.rb"
    click_on 'Ответить'

    expect(current_path).to eq question_path(question)
    within '.answers' do
      expect(page).to have_content 'Answer body'
      expect(page).to have_link 'spec_helper.rb', href: '/uploads/attachment/file/1/spec_helper.rb'
    end
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
