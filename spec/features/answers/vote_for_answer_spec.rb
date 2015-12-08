require_relative '../feature_helper'

feature 'Voting for answer' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given(:question) { create(:question, user: user) }
  given!(:answer) { create(:answer, question: question, user: author) }

  scenario 'Any users sees vote count' do
    visit question_path(question)

    within('.answer-1') do
      expect(page).to have_selector '.vote_count', text: '0'
    end
  end

  context 'Author' do
    before do
      sign_in(author)
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end
  end

  context 'Authenticated user' do
    before do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '1'

        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '-1'

        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end
  end

  context 'Unauthenticated user' do
    before do
      visit question_path(question)
    end

    scenario 'vote up for answer', js: true do
      within('.answers') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end

    scenario 'vote down for answer', js: true do
      within('.answers') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '0'
      end
    end
  end
end
