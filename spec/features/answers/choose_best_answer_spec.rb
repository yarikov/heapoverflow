require_relative '../feature_helper'

feature 'The best answer', '
  In order to help other people
  As an author of question
  I want to choose the best answer
' do
  given(:author)       { create(:user) }
  given(:user)         { create(:user) }
  given!(:question)    { create(:question, user: author) }
  given!(:answer)      { create(:answer, question: question, user: user) }
  given!(:best_answer) { create(:answer, question: question, user: user, best: true) }

  scenario 'Author of the question choose the best answer', js: true do
    sign_in(author)
    visit question_path(question)

    within ".answer-#{answer.id}" do
      page.execute_script('$(".glyphicon-ok").click()')
      expect(page).to have_css 'a.glyphicon.glyphicon-ok.best'
    end

    within ".answer-#{best_answer.id}" do
      expect(page).to_not have_css 'a.glyphicon.glyphicon-ok.best'
    end
  end

  scenario 'Authenticated user try to choose the best answer' do
    sign_in(user)
    visit question_path(question)

    expect(page).to_not have_css 'a.glyphicon.glyphicon-ok'

    within(".answer-#{best_answer.id}") do
      expect(page).to have_css 'i.glyphicon.glyphicon-ok.best'
    end
  end

  scenario 'Unauthenticated user try to choose the best answer' do
    visit question_path(question)

    expect(page).to_not have_css 'a.glyphicon.glyphicon-ok'

    within(".answer-#{best_answer.id}") do
      expect(page).to have_css 'i.glyphicon.glyphicon-ok.best'
    end
  end
end
