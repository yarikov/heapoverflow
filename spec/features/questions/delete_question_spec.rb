require_relative '../feature_helper'

feature 'Delete the question' do
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }

  scenario 'User can delete own question' do
    login_as(user)
    visit question_path(question)
    click_on 'delete'

    expect(page).to have_content 'Question was successfully destroyed'
    expect(current_path).to eq questions_path
  end

  scenario "User cannot delete someone else's question" do
    visit question_path(question)

    expect(page).to_not have_content 'delete'
  end
end
