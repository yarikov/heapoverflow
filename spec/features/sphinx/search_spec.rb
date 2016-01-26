require_relative '../sphinx_helper'

feature 'Search', '
' do
  given!(:user)     { create(:user) }
  given!(:question) { create(:question, body: 'question body', user: user) }
  given!(:answer)   { create(:answer, body: 'answer body', question: question, user: user) }
  given!(:comment)  { create(:comment, body: 'comment body', commentable: question, user: user) }

  before { index }

  scenario 'question', js: true do # DatabaseCleaner.strategy = :truncation
    visit search_path
    fill_in 'query', with: question.body
    select 'Question', from: 'resource'
    click_on 'Search'

    expect(page).to have_link question.title
    expect(page).to have_content question.body
  end

  scenario 'answer', js: true do
    visit search_path
    fill_in 'query', with: answer.body
    select 'Answer', from: 'resource'
    click_on 'Search'

    expect(page).to have_content answer.question.title
    expect(page).to have_content answer.body
  end

  scenario 'comment', js: true do
    visit search_path
    fill_in 'query', with: comment.body
    select 'Comment', from: 'resource'
    click_on 'Search'

    expect(page).to have_content comment.body
  end

  scenario 'user', js: true do
    visit search_path
    fill_in 'query', with: user.email
    select 'User', from: 'resource'
    click_on 'Search'

    expect(page).to have_content user.email
  end

  scenario 'anything', js: true do
    visit search_path
    fill_in 'query', with: 'body'
    select 'Anything', from: 'resource'
    click_on 'Search'

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    expect(page).to have_content answer.body
    expect(page).to have_content comment.body
  end
end
