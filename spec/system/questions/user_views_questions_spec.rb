# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User views questions', type: :system do
  let_it_be(:questions) { create_list(:question, 2, tag_list: 'ruby') }
  let_it_be(:question_tagged_with_rust) { create(:question, tag_list: 'rust') }

  it 'shows all questions' do
    visit questions_path

    questions.each do |question|
      expect(page).to have_content question.title
      expect(page).to have_content question.tag_list
    end

    expect(page).to have_content question_tagged_with_rust.title
    expect(page).to have_content question_tagged_with_rust.tag_list
  end

  it 'shows tagged questions' do
    visit tagged_questions_path('rust')

    questions.each do |question|
      expect(page).to_not have_content question.title
      expect(page).to_not have_content question.tag_list
    end

    expect(page).to have_content question_tagged_with_rust.title
    expect(page).to have_content question_tagged_with_rust.tag_list
  end
end
