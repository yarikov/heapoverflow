ready = ->
  $('.edit-answer-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    answer_id = $(this).data('answerId')
    $('form#edit-answer-' + answer_id).show()

  $('.answers .vote-up-off, .answers .vote-up-on, .answers .vote-down-off, .answers .vote-down-on').bind 'ajax:success', (e, data, status, xhr) ->
    answer = $.parseJSON(xhr.responseText)
    $(".answer-#{answer.id}").voteChange(answer)

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
