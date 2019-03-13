require_relative '../feature_helper'

feature 'Delete the answer' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Author can delete own answer', js: true do
    sign_in(author)

    visit question_path(question)
    accept_alert { within('.answers') { click_on 'delete' } }

    expect(page).to have_content 'Answer was successfully destroyed'
    expect(page).to_not have_content answer.body
    expect(current_path).to eq question_path(question)
  end

  scenario "Authenticated user try to delete other user's answer" do
    sign_in(user)
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'delete' }
  end

  scenario 'Unauthenticated user try to delete an answer' do
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'delete' }
  end
end
