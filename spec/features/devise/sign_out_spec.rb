require 'rails_helper'

feature 'User sign out' do
  given(:user) { create(:user) }
  scenario 'Authenticated user sign out' do
    sign_in(user)

    click_on 'Выйти'

    expect(page).to have_content 'Signed out successfully.'
  end
end
