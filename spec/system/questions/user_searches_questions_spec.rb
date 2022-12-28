# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User searches questions', type: :system do
  let_it_be(:question) { create(:question, :reindex, body: 'Question body') }
  let_it_be(:answer)   { create(:answer, :reindex, body: 'Answer body') }

  it 'it shows found questions' do
    visit questions_path

    fill_in 'query', with: 'body'
    find('#query').native.send_keys(:enter)

    expect(page).to have_link question.title
    expect(page).to have_content question.body

    expect(page).to have_link answer.question.title
    expect(page).to have_content answer.body
  end
end
