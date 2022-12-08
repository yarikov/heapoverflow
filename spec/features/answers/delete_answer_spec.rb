# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Delete the answer' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Author can delete own answer', js: true do
    login_as(author)

    visit question_path(question)
    accept_alert { within('.answers') { click_on 'Delete' } }

    expect(page).to_not have_content answer.body
    expect(current_path).to eq question_path(question)
  end

  scenario "Authenticated user try to delete other user's answer" do
    login_as(user)
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'Delete' }
  end

  scenario 'Unauthenticated user try to delete an answer' do
    visit question_path(question)

    within('.answers') { expect(page).to_not have_content 'Delete' }
  end
end
