# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User edits profile', type: :system do
  let_it_be(:user) { create(:user_with_profile) }
  let_it_be(:another) { create(:user_with_profile) }

  context 'when his profile' do
    before do
      login_as(user)
      visit edit_user_path(user)
    end

    it 'updates the profile' do
      fill_in 'Full name',   with: 'Petya Ivanov'
      fill_in 'Location',    with: 'Moscow, Russia'
      fill_in 'Description', with: 'I am a web developer'
      fill_in 'Website',     with: 'http://petya.com'
      fill_in 'Twitter',     with: 'http://twitter.com/petya'
      fill_in 'Github',      with: 'http://github.com/petya'

      click_on 'Save profile'

      expect(page).to have_content 'Petya Ivanov'
      expect(page).to have_content 'Moscow, Russia'
      expect(page).to have_content 'I am a web developer'
      expect(page).to have_link 'http://petya.com'
      expect(page).to have_link 'http://twitter.com/petya'
      expect(page).to have_link 'http://github.com/petya'
      expect(current_path).to eq user_path(user)
    end
  end

  context "when another user's profile" do
    before do
      login_as(user)
      visit edit_user_path(another)
    end

    it "redirects to another user's profile page" do
      expect(current_path).to eq user_path(another)
    end
  end
end
