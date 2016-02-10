require_relative '../feature_helper'

feature 'Edit comment' do
  given(:user)      { create(:user) }
  given(:other)     { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:comment)  { create(:comment, commentable: question, user: user) }

  scenario 'User can edit the comment', js: true do
    sign_in(user)
    visit question_path(question)

    within '.comments' do
      page.execute_script('$(".show-edit-form").click()')

      fill_in 'comment[body]', with: 'edited comment'

      click_on 'Save'

      expect(page).to_not have_content comment.body
      expect(page).to have_content 'edited comment'
      expect(page).to_not have_selector 'textarea'
    end
  end

  scenario 'Other user cannot delete the comment' do
    sign_in(other)
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.show-edit-form' }
  end

  scenario 'Guest cannot delete the comment' do
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.show-edit-form' }
  end
end
