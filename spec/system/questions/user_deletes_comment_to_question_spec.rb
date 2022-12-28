# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Delete a comment to a question', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:comment) { create(:comment, commentable: question) }

  context 'when the author of the comment' do
    let(:author) { comment.user }

    it 'deletes a comment' do
      login_as(author)
      visit question_path(question)

      within '.question .comments' do
        expect { accept_confirm { click_on(class: 'comment__delete-btn') } }.to change(question.comments, :count).by(-1)
        expect(page).to_not have_content comment.body
      end
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display the delete button" do
      login_as(user)
      visit question_path(question)

      within '.question .comments' do
        expect(page).to_not have_css '.comment__delete-btn'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display the delete button" do
      visit question_path(question)

      within '.question .comments' do
        expect(page).to_not have_css '.comment__delete-btn'
      end
    end
  end
end
