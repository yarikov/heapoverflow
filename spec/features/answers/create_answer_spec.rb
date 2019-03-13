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

    fill_in 'answer[body]', with: 'Answer body'
    click_on 'Add a file'
    all('input[type="file"]')[0].set("#{Rails.root}/spec/spec_helper.rb")
    click_on 'Add a file'
    all('input[type="file"]')[1].set("#{Rails.root}/spec/rails_helper.rb")
    click_on 'Post Your Answer'

    expect(current_path).to eq question_path(question)
    within '.answers' do
      expect(page).to have_content 'Answer body'
      expect(page).to have_link 'spec_helper.rb',
                                href: '/uploads/attachment/file/1/spec_helper.rb'
      expect(page).to have_link 'rails_helper.rb',
                                href: '/uploads/attachment/file/2/rails_helper.rb'
    end
  end

  scenario 'Authenticated user creates invalid answer', js: true do
    sign_in(user)
    visit question_path(question)

    click_on 'Post Your Answer'

    expect(page).to have_content "can't be blank"
  end

  scenario 'Unauthenticated user creates an answer' do
    visit question_path(question)
    expect(page).to_not have_button 'Post Your Answer'
  end
end
