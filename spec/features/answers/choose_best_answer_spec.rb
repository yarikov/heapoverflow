require_relative '../feature_helper'

feature 'The best answer', '
  In order to help other people
  As an author of question
  I want to choose the best answer
' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }

  context 'Author' do
    before do
      sign_in(author)
      visit question_path(question)
    end

    scenario 'sees link BEST ANSWER' do
      expect(page).to have_link 'Лучший ответ'
    end

    scenario 'try to choose the best answer', js: true do
      click_on 'Лучший ответ'

      expect(page).to have_content 'You chose the best answer'
    end
  end

  scenario 'Authenticated user try to choose the best answer' do
    sign_in(user)
    visit question_path(question)

    expect(page).to_not have_link 'Лучший ответ'
  end

  scenario 'Unauthenticated user try to choose the best answer' do
    visit question_path(question)

    expect(page).to_not have_link 'Лучший ответ'
  end
end
