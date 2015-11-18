require 'rails_helper'

feature 'User sign out' do
  scenario 'Authenticated user sign out' do
    User.create!(email: 'user@test.com', password: '12345678')

    visit new_user_session_path
    fill_in 'Email', with: 'user@test.com'
    fill_in 'Password', with: '12345678'
    click_on 'Log in'

    click_on 'Выйти'

    expect(page).to have_content 'Signed out successfully.'
  end
end
