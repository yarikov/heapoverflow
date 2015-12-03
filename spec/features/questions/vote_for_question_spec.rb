require_relative '../feature_helper'

feature 'Voting for question' do
  given(:author) { create(:user) }
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: author) }

  scenario 'Any users sees vote count' do
    visit question_path(question)

    within('.question') do
      expect(page).to have_selector '.vote_count', text: '0'
    end
  end

  context 'Author' do
    before do
      sign_in(author)
      visit question_path(question)
    end

    scenario 'vote up for question' do
      within('.question') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_content 'Автор не может проголосовать за свой вопрос'
      end
    end

    scenario 'vote down for question' do
      within('.question') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_content 'Автор не может проголосовать за свой вопрос'
      end
    end
  end

  context 'Authenticated user' do
    before do
      sign_in(user)
      visit question_path(question)
    end

    scenario 'vote up for question' do
      within('.question') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '1'

        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '1'
        expect(page).to have_content 'Вы уже проголосовали...'
      end
    end

    scenario 'vote down for question' do
      within('.question') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '-1'

        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '-1'
        expect(page).to have_content 'Вы уже проголосовали...'
      end
    end
  end

  context 'Unauthenticated user' do
    before do
      visit question_path(question)
    end

    scenario 'vote up for question' do
      within('.question') do
        find('.vote_up').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_content 'You need to sign in or sign up before continuing'
      end
    end

    scenario 'vote down for question' do
      within('.question') do
        find('.vote_down').click
        expect(page).to have_selector '.vote_count', text: '0'
        expect(page).to have_content 'You need to sign in or sign up before continuing'
      end
    end
  end
end
