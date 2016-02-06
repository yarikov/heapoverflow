require_relative '../feature_helper'

feature 'The list of users' do
  given!(:users) { create_list(:user_with_profile, 2) }

  scenario 'The user sees the list of users' do
    visit root_path

    click_on 'Users'

    users.each do |user|
      expect(page).to have_css("img[src*='#{user.avatar.small.url}']")
      expect(page).to have_link user.full_name
    end
  end
end
