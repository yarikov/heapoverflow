# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Sign up', type: :system do
  context 'with new email' do
    it 'works' do
      visit new_user_registration_path
      submit_form('Vasya Pupkin', 'vasya@pupkin.test', 'password')
      expect(page).to have_content 'A message with a confirmation link has been sent'

      open_email 'vasya@pupkin.test'
      current_email.click_link 'Confirm my account'
      expect(page).to have_content 'Your email address has been successfully confirmed'
    end
  end

  context 'with an already existing email' do
    let(:user) { create(:user) }

    it 'displays an error' do
      visit new_user_registration_path
      submit_form('Vasya Pupkin', user.email, 'password')
      expect(page).to have_content 'has already been taken'
    end
  end

  def submit_form(full_name, email, password)
    within '.sign-form' do
      fill_in 'Full name', with: full_name
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      fill_in 'Password confirmation', with: password
      click_on 'Sign up'
    end
  end
end
