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
    within '.search' do
      fill_in 'query', with: question.body
      select 'Question', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_link question.title
    expect(page).to have_content question.body
  end

  scenario 'answer', js: true do
    within '.search' do
      fill_in 'query', with: answer.body
      select 'Answer', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content answer.question.title
    expect(page).to have_content answer.body
  end

  scenario 'comment', js: true do
    within '.search' do
      fill_in 'query', with: comment.body
      select 'Comment', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content comment.body
  end

  scenario 'user', js: true do
    within '.search' do
      fill_in 'query', with: user.full_name
      select 'User', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content user.full_name
  end

  scenario 'anything', js: true do
    within '.search' do
      fill_in 'query', with: 'body'
      select 'Anything', from: 'resource'
      click_on 'Search'
    end

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    expect(page).to have_content answer.body
    expect(page).to have_content comment.body
  end
end
