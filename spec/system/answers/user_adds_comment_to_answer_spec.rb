# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Add a comment to an answer', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:answer)   { create(:answer, question: question) }

  context 'when the authenticated user' do
    let(:user) { create(:user) }

    it 'creates new comment' do
      login_as(user)
      visit question_path(question)

      within ".answer-#{answer.id}" do
        click_on 'Add a comment'
        fill_in 'comment[body]', with: 'New comment'

        expect { click_on('Add') }.to change(answer.comments, :count).by(1)
        expect(page).to have_content 'New comment'
      end
    end
  end

  context 'when the guest' do
    it "doesn't display a link to add a comment" do
      visit question_path(question)

      within ".answer-#{answer.id}" do
        expect(page).to_not have_link 'Add a comment'
      end
    end
  end
end
