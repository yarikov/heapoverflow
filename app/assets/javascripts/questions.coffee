ready = ->
  $('.edit-question-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    question_id = $(this).data('questionId')
    $('form#edit_question_' + question_id).show()

  $('.vote_up').bind 'ajax:success', (e, data, status, xhr) ->
    $('.vote_count').html(xhr.responseText)

  $('.vote_down').bind 'ajax:success', (e, data, status, xhr) ->
    $('.vote_count').html(xhr.responseText)

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
