require 'rails_helper'

feature 'Delete the answer' do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given(:answer) { create(:answer, question: question, user: user) }

  before { answer }

  scenario 'User can delete own answer' do
    sign_in(user)

    visit question_path(question)
    click_on 'Удалить ответ'

    expect(page).to have_content 'Ответ на вопрос успешно удален'
    expect(page).to_not have_content answer.body
    expect(current_path).to eq question_path(question)
  end

  scenario "User cannot delete someone else's answer" do
    visit question_path(question)

    expect(page).to_not have_content 'Удалить ответ'
  end
end
