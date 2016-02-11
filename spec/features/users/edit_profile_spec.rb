require_relative '../feature_helper'

feature 'Edit profile' do
  given!(:user) { create(:user) }

  scenario 'The user can edit profile' do
    sign_in user
    visit edit_user_path(user)

    fill_in 'Full name',   with: 'Petya Ivanov'
    fill_in 'Location',    with: 'Moscow, Russia'
    fill_in 'Description', with: 'I am the best web developer'
    fill_in 'Website',     with: 'http://petya.com'
    fill_in 'Twitter',     with: 'http://twitter.com/petya'
    fill_in 'Github',      with: 'http://github.com/petya'

    click_on 'Save profile'

    expect(current_path).to eq user_path(user)
    expect(page).to have_content 'Petya Ivanov'
    expect(page).to have_content 'Moscow, Russia'
    expect(page).to have_content 'I am the best web developer'
    expect(page).to have_link 'http://petya.com'
    expect(page).to have_link 'http://twitter.com/petya'
    expect(page).to have_link 'http://github.com/petya'
  end
end
