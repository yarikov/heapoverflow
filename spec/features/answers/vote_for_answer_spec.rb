# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Voting for answer' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Any users sees vote count' do
    visit question_path(question)

    within('.answers') do
      expect(page).to have_selector '.vote_count', text: '0'
    end
  end

  context 'Author' do
    before do
      login_as(author)
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote-up-off').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-up-off'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote-down-off').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-down-off'
      end
    end
  end

  context 'Authenticated user' do
    before do
      login_as(user)
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote-up-off').click
        expect(page).to have_selector '.vote_count', text: '1'
        expect(page).to have_selector '.vote-up-on'

        find('.vote-up-on').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-up-off'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote-down-off').click
        expect(page).to have_selector '.vote_count', text: '-1'
        expect(page).to have_selector '.vote-down-on'

        find('.vote-down-on').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-down-off'
      end
    end
  end

  context 'Unauthenticated user' do
    before do
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote-up-off').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-up-off'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote-down-off').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_selector '.vote-down-off'
      end
    end
  end
end
