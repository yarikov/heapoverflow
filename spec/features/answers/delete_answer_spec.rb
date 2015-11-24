require_relative '../feature_helper'

feature 'Delete the answer' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Author can delete own answer', js: true do
    sign_in(author)

    visit question_path(question)
    click_on 'Удалить ответ'

    expect(page).to have_content 'Ответ на вопрос успешно удален'
    expect(page).to_not have_content answer.body
    expect(current_path).to eq question_path(question)
  end

  scenario "Authenticated user try to delete other user's answer" do
    sign_in(user)
    visit question_path(question)

    expect(page).to_not have_content 'Удалить ответ'
  end

  scenario 'Unauthenticated user try to delete an answer' do
    visit question_path(question)

    expect(page).to_not have_content 'Удалить ответ'
  end
end
