# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'Question subscription', type: :system do
  let_it_be(:question) { create(:question) }

  context 'when the user subscribes to a question' do
    let(:user) { create(:user) }

    it 'creates a subscription' do
      login_as(user)
      visit question_path(question)

      expect { click_on(class: 'subscription__btn') }.to change(user.subscriptions, :count).by(1)

      within '.subscription' do
        expect(page).to have_css '.subscription__btn--active'
        expect(page).to have_content '2'
      end
    end
  end

  context 'when the user unsubscribes from a question' do
    let(:user) { question.user }

    it 'deletes a subscription' do
      login_as(user)
      visit question_path(question)

      expect { click_on(class: 'subscription__btn') }.to change(user.subscriptions, :count).by(-1)

      within '.subscription' do
        expect(page).to_not have_css '.subscription__btn--active'
        expect(page).to have_content '0'
      end
    end
  end
end
