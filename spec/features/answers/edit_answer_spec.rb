require_relative '../feature_helper'

feature 'Answer editing', '
  In order to fix mistake
  As an author of answer
  I want to edit my answer
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

    scenario 'sees link to Edit' do
      within('.answers') { expect(page).to have_link 'edit' }
    end

    scenario 'try to edit his answer', js: true do
      within '.answers' do
        click_on 'edit'
        fill_in 'answer[body]', with: 'edited answer'
        click_on 'Save'

        expect(page).to_not have_content answer.body
        expect(page).to have_content 'edited answer'
        expect(page).to_not have_selector 'textarea'
      end
      expect(page).to have_content 'Answer was successfully updated'
    end
  end

  scenario "Authenticated user try to edit other user's answer" do
    sign_in(user)
    visit question_path(question)

    within('.answers') { expect(page).to_not have_link 'edit' }
  end

  scenario 'Unauthenticated user try to edit answer' do
    visit question_path(question)

    within('.answers') { expect(page).to_not have_link 'edit' }
  end
end
