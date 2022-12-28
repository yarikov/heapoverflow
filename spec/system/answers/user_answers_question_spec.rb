# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User answers a question', type: :system do
  let_it_be(:question) { create(:question) }

  context 'when the authenticated user' do
    let(:user) { create(:user) }

    it 'creates an answer' do
      login_as(user)
      visit question_path(question)

      fill_in 'answer[body]', with: 'New answer'
      click_on 'Post Your Answer'

      within '.answers' do
        expect(page).to have_content 'New answer'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the form for a new answer" do
      visit question_path(question)

      expect(page).to_not have_css 'form#new_answer'
      expect(page).to_not have_button 'Post Your Answer'
    end
  end
end
