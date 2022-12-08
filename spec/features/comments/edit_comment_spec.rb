# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Edit comment' do
  given(:user)      { create(:user) }
  given(:other)     { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:comment)  { create(:comment, commentable: question, user: user) }

  scenario 'User can edit the comment', js: true do
    login_as(user)
    visit question_path(question)

    within '.comments' do
      find('.show-edit-form').click
      fill_in 'comment[body]', with: 'edited comment'
      click_on 'Save'

      expect(page).to_not have_content comment.body
      expect(page).to have_content 'edited comment'
      expect(page).to_not have_selector 'textarea'
    end
  end

  scenario 'Other user cannot delete the comment' do
    login_as(other)
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.show-edit-form' }
  end

  scenario 'Guest cannot delete the comment' do
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.show-edit-form' }
  end
end
