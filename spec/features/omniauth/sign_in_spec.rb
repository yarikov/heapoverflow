require_relative '../feature_helper'

feature 'User sign in' '
  In order to be able to ask question
  As an User
  I want to be able to sign in
' do
  describe 'with Facebook' do
    scenario 'fail' do
      visit new_user_session_path

      OmniAuth.config.mock_auth[:facebook] = :invalid_credentials
      click_on 'Sign in with Facebook'

      expect(page).to have_content 'Could not authenticate you from Facebook'
    end

    scenario 'success' do
      visit new_user_session_path

      mock_auth_hash
      click_on 'Sign in with Facebook'

      expect(page).to have_content 'Successfully authenticated from Facebook account'
    end
  end

  describe 'with Twitter' do
    scenario 'fail' do
      visit new_user_session_path

      OmniAuth.config.mock_auth[:twitter] = :invalid_credentials
      click_on 'Sign in with Twitter'

      expect(page).to have_content 'Could not authenticate you from Twitter'
    end

    scenario 'success' do
      visit new_user_session_path

      mock_auth_hash
      click_on 'Sign in with Twitter'
      fill_in 'Email', with: 'test@email.com'
      click_on 'Подтвердить'
      expect(page).to have_content 'You have to confirm your email address before continuing'

      open_email 'test@email.com'
      current_email.click_link 'Confirm my account'
      expect(page).to have_content 'Your email address has been successfully confirmed'

      click_on 'Sign in with Twitter'
      expect(page).to have_content 'Successfully authenticated from Twitter account'
    end
  end
end