ready = ->
  $('.edit-question-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    question_id = $(this).data('questionId')
    $('form#edit_question_' + question_id).show()

  $('.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on').bind 'ajax:success', (e, data, status, xhr) ->
    question = $.parseJSON(xhr.responseText)
    $('.question').voteChange(question)

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
