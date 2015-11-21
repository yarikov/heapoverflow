require_relative '../feature_helper'

feature 'Delete the question' do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'User can delete own question' do
    sign_in(user)
    visit question_path(question)
    click_on 'Удалить вопрос'

    expect(page).to have_content 'Вопрос успешно удален'
    expect(current_path).to eq questions_path
  end

  scenario "User cannot delete someone else's question" do
    visit question_path(question)

    expect(page).to_not have_content 'Удалить вопрос'
  end
end
