require_relative '../feature_helper'

feature 'Ask question' do
  given(:user) { create(:user) }

  scenario 'when authenticated user', js: true do
    sign_in(user)
    visit new_question_path

    fill_in 'Суть вопроса', with: 'Question title'
    fill_in 'Детали вопроса', with: 'Question body'
    fill_in 'Tags', with: 'ruby-on-rails'
    click_on 'Добавить файл'
    all('input[type="file"]')[0].set("#{Rails.root}/spec/spec_helper.rb")
    click_on 'Добавить файл'
    all('input[type="file"]')[1].set("#{Rails.root}/spec/rails_helper.rb")
    click_on 'Опубликовать'

    expect(page).to have_content 'Question title'
    expect(page).to have_content 'Question body'
    expect(page).to have_content 'ruby-on-rails'
    expect(page).to have_link 'spec_helper.rb', href: '/uploads/attachment/file/1/spec_helper.rb'
    expect(page).to have_link 'rails_helper.rb', href: '/uploads/attachment/file/2/rails_helper.rb'
  end

  scenario 'when unauthenticated user' do
    visit questions_path
    click_on 'Задать вопрос'

    expect(page).to have_content 'You need to sign in or sign up before continuing.'
  end
end