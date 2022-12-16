# frozen_string_literal: true

require_relative '../feature_helper'

feature 'Search', search: true do
  given!(:user)     { create(:user, :reindex) }
  given!(:question) { create(:question, :reindex, body: 'question body', user: user) }
  given!(:answer)   { create(:answer, :reindex, body: 'answer body', question: question, user: user) }
  given!(:comment)  { create(:comment, :reindex, body: 'comment body', commentable: question, user: user) }

  before do
    visit search_path
  end

  scenario 'question', js: true do # DatabaseCleaner.strategy = :truncation
    within '.search-form' do
      fill_in 'query', with: question.body
      select 'Question', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_link question.title
    expect(page).to have_content question.body
  end

  scenario 'answer', js: true do
    within '.search-form' do
      fill_in 'query', with: answer.body
      select 'Answer', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content answer.question.title
    expect(page).to have_content answer.body
  end

  scenario 'anything', js: true do
    within '.search-form' do
      fill_in 'query', with: 'body'
      select 'Anything', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    expect(page).to have_content answer.body
  end
end
