editQuestion = (e) ->
  e.preventDefault();
  $(this).hide();
  questionId = $(this).data('questionId')
  $("form#edit_question_#{questionId}").show()

voteQuestion = (e, data, status, xhr) ->
  question = $.parseJSON(xhr.responseText)
  $('.question').voteChange(question)

$(document)
  .on('click', '.edit-question-link', editQuestion)
  .on('ajax:success', '.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on', voteQuestion)
