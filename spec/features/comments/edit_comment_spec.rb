require_relative '../feature_helper'

feature 'Edit comment' do
  given(:user)      { create(:user) }
  given(:other)     { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:comment)  { create(:comment, commentable: question, user: user) }

  scenario 'User can edit the comment', js: true do
    sign_in(user)
    visit question_path(question)

    page.execute_script('$(".edit-comment").click()')

    fill_in 'Comment', with: 'edited comment'
    click_on 'Update Comment'

    expect(page).to_not have_content comment.body
    expect(page).to have_content 'edited comment'
    within('.comments') { expect(page).to_not have_selector 'textarea' }
  end

  scenario 'Other user cannot delete the comment' do
    sign_in(other)
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.edit-comment' }
  end

  scenario 'Guest cannot delete the comment' do
    visit question_path(question)

    within('.comments') { expect(page).to_not have_css '.edit-comment' }
  end
end
