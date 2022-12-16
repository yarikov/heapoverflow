# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Voting for question' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: author) }

  scenario 'Any users sees vote count' do
    visit question_path(question)

    within('.question') do
      expect(page).to have_selector '.voting__count', text: '0'
    end
  end

  context 'Author' do
    before do
      login_as(author)
      visit question_path(question)
    end

    scenario 'vote up for question', js: true do
      within('.question') do
        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__up-btn--active'
      end
    end

    scenario 'vote down for question', js: true do
      within('.question') do
        find('.voting__down-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__down-btn--active'
      end
    end
  end

  context 'Authenticated user' do
    before do
      login_as(user)
      visit question_path(question)
    end

    scenario 'vote up for question', js: true do
      within('.question') do
        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '1'
        expect(page).to have_selector '.voting__up-btn--active'

        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__up-btn--active'
      end
    end

    scenario 'vote down for question', js: true do
      within('.question') do
        find('.voting__down-btn').click
        expect(page).to have_selector '.voting__count', text: '-1'
        expect(page).to have_selector '.voting__down-btn--active'

        find('.voting__down-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__down-btn--active'
      end
    end
  end

  context 'Unauthenticated user' do
    before do
      visit question_path(question)
    end

    scenario 'vote up for question', js: true do
      within('.question') do
        find('.voting__up-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__up-btn--active'
      end
    end

    scenario 'vote down for question', js: true do
      within('.question') do
        find('.voting__down-btn').click
        expect(page).to have_selector '.voting__count', text: '0'
        expect(page).to_not have_selector '.voting__down-btn--active'
      end
    end
  end
end
