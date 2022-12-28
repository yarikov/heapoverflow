# frozen_string_literal: true

require 'system_helper'

RSpec.describe 'User views question', type: :system do
  let_it_be(:question) { create(:question, :with_answers, :with_comments) }

  it 'shows content' do
    visit question_path(question)

    expect(page).to have_content question.title
    expect(page).to have_content question.body
    expect(page).to have_content question.tag_list

    question.answers.each do |answer|
      expect(page).to have_content answer.body
    end

    question.comments.each do |comment|
      expect(page).to have_content comment.body
    end
  end
end
