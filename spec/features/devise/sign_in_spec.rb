require_relative '../feature_helper'

feature 'User sign in' do
  given(:user) { create(:user) }

  scenario 'Registered user try to sign in' do
    visit new_user_session_path

    within '.sign-form' do
      fill_in 'Email', with: user.email
      fill_in 'Password', with: user.password
      click_on 'Sign in'
    end

    expect(page).to have_content 'Signed in successfully'
    expect(current_path).to eq root_path
  end

  scenario 'Unregistered user try to sign in' do
    visit new_user_session_path

    within '.sign-form' do
      fill_in 'Email', with: 'wrong@test.com'
      fill_in 'Password', with: '12345678'
      click_on 'Sign in'
    end

    expect(page).to have_content 'Invalid Email or password'
    expect(current_path).to eq new_user_session_path
  end
end
