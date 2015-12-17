ready = ->
  PrivatePub.subscribe "/questions", (data, channel) ->
    question = $.parseJSON(data['question'])
    $('.content').append(JST['templates/question'](question: question))

editQuestion = (e) ->
  e.preventDefault()
  $(this).hide()
  questionId = $(this).data('questionId')
  $("form#edit_question_#{questionId}").show()

voteQuestion = (e, data, status, xhr) ->
  question = $.parseJSON(xhr.responseText)
  $('.question').voteChange(question)

newComment = (e) ->
  e.preventDefault()
  $(this).parent().find('.new_comment').show()

$(document)
  .ready(ready)
  .on('click', '.edit-question-link', editQuestion)
  .on('click', '.new-comment-link', newComment)
  .on('ajax:success', '.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on', voteQuestion)
