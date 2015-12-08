ready = ->
  $('.edit-question-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    question_id = $(this).data('questionId')
    $('form#edit_question_' + question_id).show()

  $('.question .vote_up, .question .vote_down').bind 'ajax:success', (e, data, status, xhr) ->
    question = $.parseJSON(xhr.responseText)
    $('.question .vote_count').html(question.vote_count)

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
