# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Edit a question', type: :system do
  let_it_be(:question) { create(:question) }

  context 'when the author' do
    let(:author) { question.user }

    it 'updates a question' do
      login_as(author)
      visit question_path(question)

      within '.question' do
        click_on 'Edit'
        fill_in 'Title', with: 'Edited question title'
        fill_in 'Body', with: 'Edited question body'
        click_on 'Save'

        expect(page).to have_content 'Edited question body'
        expect(page).to_not have_selector 'text_field'
        expect(page).to_not have_selector 'textarea'
      end

      within '.headline' do
        expect(page).to have_content 'Edited question title'
      end
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the edit link" do
      login_as(user)
      visit question_path(question)

      within '.question' do
        expect(page).to_not have_link 'Edit'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the edit link" do
      visit question_path(question)

      within '.question' do
        expect(page).to_not have_link 'Edit'
      end
    end
  end
end
