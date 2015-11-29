require_relative '../feature_helper'

feature 'Delete file from answer' do
  given(:author) { create(:user) }
  given!(:question) { create(:question, user: author) }
  given!(:answer) { create(:answer, question: question, user: author) }
  given!(:file) { create(:attachment, attachable: answer) }

  context 'Author' do
    before do
      sign_in(author)
      visit question_path(question)
    end

    scenario 'sees link to file' do
      expect(page).to have_link file.file.identifier
    end

    scenario 'try to delete the file', js: true do
      within '.answers' do
        click_on 'Редактировать'
        click_on 'Удалить файл'
        click_on 'Сохранить'

        expect(page).to_not have_link file.file.identifier
      end
    end
  end
end
