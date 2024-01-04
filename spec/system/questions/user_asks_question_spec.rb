# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Ask a question', type: :system do
  context 'when the authenticated user' do
    let(:user) { create(:user) }

    it 'creates new question' do
      login_as(user)
      visit questions_path

      click_on 'Ask Question'
      fill_in 'Title', with: 'Question title'
      fill_in 'Body', with: 'Question body'
      fill_in 'Tags', with: 'ruby-on-rails'

      expect { click_on('Post Your Question') }.to change(user.questions, :count).by(1)

      expect(page).to have_content 'Question title'
      expect(page).to have_content 'Question body'
      expect(page).to have_content 'ruby-on-rails'
    end
  end

  context 'when the guest' do
    it 'redirects to the login page' do
      visit questions_path
      click_on 'Ask Question'

      expect(page).to have_content 'You need to sign in or sign up before continuing.'
      expect(page).to have_current_path(new_user_session_path)
    end
  end
end
