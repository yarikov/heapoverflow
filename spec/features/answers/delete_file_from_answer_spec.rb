require_relative '../feature_helper'

feature 'Delete file from answer' do
  given(:author) { create(:user) }
  given!(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }
  given!(:file) { create(:attachment, attachable: answer) }

  scenario 'Author try to delete the file', js: true do
    sign_in(author)
    visit question_path(question)

    within '.answers' do
      click_on 'Редактировать'
      click_on 'Удалить файл'
      click_on 'Сохранить'

      expect(page).to_not have_link file.file.identifier
    end
  end
end
