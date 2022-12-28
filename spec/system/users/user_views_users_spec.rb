# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User views users', type: :system do
  let_it_be(:users) { create_list(:user_with_profile, 2) }

  it 'shows all users' do
    visit root_path

    click_on 'Users'

    users.each do |user|
      expect(page).to have_css("img[src*='#{avatar_path(user, :thumb)}']")
      expect(page).to have_link user.full_name
      expect(page).to have_content user.location
    end
  end
end
