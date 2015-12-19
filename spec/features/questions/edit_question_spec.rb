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
      sign_in(author)
      visit question_path(question)
    end

    scenario 'sees link to Edit' do
      within('.question') { expect(page).to have_link 'Редактировать' }
    end

    scenario 'try to edit his question', js: true do
      within '.question' do
        click_on 'Редактировать'
        fill_in 'Суть вопроса', with: 'edited question title'
        fill_in 'Детали вопроса', with: 'edited question body'
        click_on 'Сохранить'

        expect(page).to_not have_content question.body
        expect(page).to have_content 'edited question title'
        expect(page).to have_content 'edited question body'
        expect(page).to_not have_selector 'text_field'
        expect(page).to_not have_selector 'textarea'
      end
      expect(page).to have_content 'Question was successfully updated'
    end
  end

  scenario "Authenticated user try to edit other user's question" do
    sign_in(user)
    visit question_path(question)

    within('.question') { expect(page).to_not have_link 'Редактировать' }
  end

  scenario 'Unauthenticated user try to edit question' do
    visit question_path(question)

    within('.question') { expect(page).to_not have_link 'Редактировать' }
  end
end
