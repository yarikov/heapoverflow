require_relative '../feature_helper'

feature 'View the question', '
  In order to get answers
  As an user
  I want to view the question and answers
' do
  given(:user) { create(:user) }
  given!(:question) { create(:question, user: user) }
  given!(:answers) { create_list(:answer, 3, question: question, user: user) }

  scenario 'User view the question and answers' do
    visit question_path(question)

    expect(page).to have_content question.title
    expect(page).to have_content question.body

    answers.each { |answer| expect(page).to have_content answer.body }
  end
end
