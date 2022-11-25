require_relative '../feature_helper'

feature 'Delete the comment' do
  given(:user)     { create(:user) }
  given(:other)    { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:comment) { create(:comment, commentable: question, user: user) }

  scenario 'User can delete the comment', js: true do
    login_as(user)

    visit question_path(question)
    page.execute_script('$(".delete-comment").click()')

    expect(page).to_not have_content comment.body
    expect(current_path).to eq question_path(question)
  end

  scenario 'Other user cannot delete the comment' do
    login_as(other)
    visit question_path(question)

    expect(page).to_not have_css '.delete-comment'
  end

  scenario 'Guest cannot delete the comment' do
    visit question_path(question)

    expect(page).to_not have_css '.delete-comment'
  end
end
