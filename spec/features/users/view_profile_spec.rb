# frozen_string_literal: true

require_relative '../feature_helper'

feature 'View profile' do
  given!(:user) { create(:user_with_profile) }
  given(:other) { create(:user) }

  scenario 'Any users can view profile' do
    visit user_path(user)

    expect(page).to have_css("img[src*='#{avatar_path(user, :medium)}']")
    expect(page).to have_content user.full_name
    expect(page).to have_content user.description
    expect(page).to have_link user.website
    expect(page).to have_link user.twitter
    expect(page).to have_link user.github
    within('.questions') { expect(page).to have_content user.questions.count }
    within('.answers')   { expect(page).to have_content user.answers.count }
  end

  scenario 'The user sees link to edit profile' do
    login_as user
    visit user_path(user)

    expect(page).to have_link 'Edit Profile'
  end

  scenario 'Other user does not see link to edit profile' do
    login_as other
    visit user_path(user)

    within('.profile') { expect(page).to_not have_link 'Edit Profile' }
  end

  scenario 'Guest does not see link to edit profile' do
    visit user_path(user)

    within('.profile') { expect(page).to_not have_link 'Edit Profile' }
  end
end
