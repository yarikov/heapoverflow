# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Question editing', '
  In order to fix mistake
  As an author of question
  I want to edit my question
' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: author) }

  context 'Author' do
    before do
      login_as(author)
      visit question_path(question)
    end

    scenario 'sees link to Edit' do
      within('.question') { expect(page).to have_link 'Edit' }
    end

    scenario 'try to edit his question', js: true do
      within '.question' do
        click_on 'Edit'
        fill_in 'Title', with: 'edited question title'
        fill_in 'Body', with: 'edited question body'
        click_on 'Save'

        expect(page).to_not have_content question.body
        expect(page).to have_content 'edited question body'
        expect(page).to_not have_selector 'text_field'
        expect(page).to_not have_selector 'textarea'
      end

      within '.headline' do
        expect(page).to have_content 'edited question title'
      end
    end
  end

  scenario "Authenticated user try to edit other user's question" do
    login_as(user)
    visit question_path(question)

    within('.question') { expect(page).to_not have_link 'Edit' }
  end

  scenario 'Unauthenticated user try to edit question' do
    visit question_path(question)

    within('.question') { expect(page).to_not have_link 'Edit' }
  end
end
