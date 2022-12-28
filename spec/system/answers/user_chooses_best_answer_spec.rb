# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User chooses the best answer', type: :system do
  let_it_be(:question) { create(:question) }
  let_it_be(:answer1) { create(:answer, question: question, best: false) }
  let_it_be(:answer2) { create(:answer, question: question, best: true) }

  context 'when the author' do
    let(:author) { question.user }

    it 'works' do
      login_as(author)
      visit question_path(question)

      within ".answer-#{answer1.id}" do
        find('.best-answer__btn').click
        expect(page).to have_css 'a.best-answer__btn--active'
      end

      within ".answer-#{answer2.id}" do
        expect(page).to_not have_css 'a.best-answer__btn--active'
      end
    end
  end

  context 'when another user' do
    let(:user) { create(:user) }

    it "doesn't display a button" do
      login_as(user)
      visit question_path(question)

      expect(page).to_not have_css 'a.best-answer__btn'
    end
  end

  context 'when the guest' do
    it "doesn't display a button" do
      visit question_path(question)

      expect(page).to_not have_css 'a.best-answer__btn'
    end
  end
end
