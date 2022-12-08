# frozen_string_literal: true

require_relative '../feature_helper'

feature 'List of questions' do
  given(:user)       { create(:user) }
  given!(:question)  { create(:question, user: user, tag_list: 'python') }
  given!(:questions) { create_list(:question, 2, user: user, tag_list: 'ruby') }

  background do
    visit questions_path
  end

  scenario 'The user sees list of questions' do
    questions.each do |question|
      expect(page).to have_content question.title
      expect(page).to have_content question.tag_list
    end
  end

  scenario 'The user is looking for questions using tags' do
    click_on 'Tags'

    expect(page).to have_content 'ruby'
    expect(page).to have_content 'python'

    click_on 'python'

    expect(page).to have_content question.title
    expect(page).to have_content question.tag_list
  end
end
