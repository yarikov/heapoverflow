# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Edit a comment to a question', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:comment) { create(:comment, commentable: question) }

  context 'when the author of the comment' do
    let(:author) { comment.user }

    it 'updates the comment' do
      login_as(author)
      visit question_path(question)

      within '.question .comments' do
        click_on(class: 'comment__edit-btn')
        fill_in 'comment[body]', with: 'Edited comment'
        click_on 'Save'

        expect(page).to have_content 'Edited comment'
      end
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the edit button" do
      login_as(user)
      visit question_path(question)

      within '.question .comments' do
        expect(page).to_not have_css '.comment__edit-btn'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the edit button" do
      visit question_path(question)

      within '.question .comments' do
        expect(page).to_not have_css '.comment__edit-btn'
      end
    end
  end
end
