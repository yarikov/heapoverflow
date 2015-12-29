require_relative '../feature_helper'

feature 'User sign up' '
  In order to be able to ask question
  As an User
  I want to be able to sign up
' do
  scenario 'User sign up with new email' do
    visit new_user_registration_path
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    fill_in 'Password confirmation', with: '12345678'
    click_on 'Sign up'
    expect(page).to have_content 'A message with a confirmation link has been sent'

    open_email 'user@test.com'
    current_email.click_link 'Confirm my account'
    expect(page).to have_content 'Your email address has been successfully confirmed'
  end

  given(:user) { create(:user) }

  scenario 'User sign up with exist email' do
    visit new_user_registration_path
    fill_in 'Email', with: user.email
    fill_in 'Password', with: user.password
    fill_in 'Password confirmation', with: user.password
    click_on 'Sign up'

    expect(page).to have_content 'Email has already been taken'
  end
end
