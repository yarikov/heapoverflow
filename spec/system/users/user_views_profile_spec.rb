# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User views profile', type: :system do
  let_it_be(:user) { create(:user_with_profile) }
  let_it_be(:another) { create(:user_with_profile) }

  context 'when his profile' do
    before do
      login_as(user)
      visit user_path(user)
    end

    it 'displays the edit link' do
      expect(page).to have_link 'Edit Profile'
    end

    it 'displays the content' do
      expect(page).to have_css("img[src*='#{avatar_path(user, :medium)}']")
      expect(page).to have_content user.full_name
      expect(page).to have_content user.description
      expect(page).to have_link user.website
      expect(page).to have_link user.twitter
      expect(page).to have_link user.github
      expect(page).to have_content "#{user.questions.count} question"
      expect(page).to have_content "#{user.answers.count} answer"
    end
  end

  context "when another user's profile" do
    before do
      login_as(user)
      visit user_path(another)
    end

    it "doesn't display the edit link" do
      expect(page).to_not have_link 'Edit Profile'
    end

    it 'displays the content' do
      expect(page).to have_css("img[src*='#{avatar_path(another, :medium)}']")
      expect(page).to have_content another.full_name
      expect(page).to have_content another.description
      expect(page).to have_link another.website
      expect(page).to have_link another.twitter
      expect(page).to have_link another.github
      expect(page).to have_content "#{another.questions.count} question"
      expect(page).to have_content "#{another.answers.count} answer"
    end
  end
end
