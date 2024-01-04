# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Delete a question', type: :system do
  let_it_be(:question) { create(:question) }

  context 'when the author' do
    let(:author) { question.user }

    it 'deletes a question' do
      login_as(author)
      visit question_path(question)

      within '.question' do
        expect { accept_confirm { click_on('Delete') } }.to change(author.questions, :count).by(-1)
      end

      expect(page).to have_content 'Question was successfully destroyed'
      expect(page).to have_current_path(questions_path)
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the delete link" do
      login_as(user)
      visit question_path(question)

      within '.question' do
        expect(page).to_not have_link 'Delete'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the delete link" do
      visit question_path(question)

      within '.question' do
        expect(page).to_not have_link 'Delete'
      end
    end
  end
end
