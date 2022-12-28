# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Sign in', type: :system do
  let_it_be(:user) { create(:user) }

  context 'with the correct credentials' do
    it 'works' do
      visit new_user_session_path

      submit_form(user.email, user.password)

      expect(page).to have_content 'Signed in successfully'
      expect(current_path).to eq root_path
    end
  end

  context 'with wrong email' do
    it 'displays an error' do
      visit new_user_session_path

      submit_form('wrong@email.test', user.password)

      expect(page).to have_content 'Invalid Email or password'
      expect(current_path).to eq new_user_session_path
    end
  end

  context 'with wrong password' do
    it 'displays an error' do
      visit new_user_session_path

      submit_form(user.email, 'wrong password')

      expect(page).to have_content 'Invalid Email or password'
      expect(current_path).to eq new_user_session_path
    end
  end

  def submit_form(email, password)
    within '.sign-form' do
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_on 'Sign in'
    end
  end
end
