require 'rails_helper'

feature 'List of questions', '
  In order to find an interesting question
  As an user
  I want to view list of questions
' do
  given!(:questions) { create_list(:question, 3) }

  scenario 'User view list of questions' do
    visit questions_path

    questions.each { |question| expect(page).to have_content question.title }
  end
end
