require_relative '../feature_helper'

feature 'Delete file from question' do
  given(:author) { create(:user) }
  given!(:question) { create(:question, user: author) }
  given!(:file) { create(:attachment, attachable: question) }

  scenario 'Author try to delete the file', js: true do
    sign_in(author)
    visit question_path(question)

    within '.question' do
      click_on 'Редактировать'
      click_on 'Удалить'
      click_on 'Сохранить'

      expect(page).to_not have_link file.file.identifier
    end
  end
end
