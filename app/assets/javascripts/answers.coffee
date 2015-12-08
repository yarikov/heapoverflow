ready = ->
  $('.edit-answer-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    answer_id = $(this).data('answerId')
    $('form#edit-answer-' + answer_id).show()

  $('.answers .vote_up, .answers .vote_down').bind 'ajax:success', (e, data, status, xhr) ->
    answer = $.parseJSON(xhr.responseText)
    $(".answer-#{answer.id} .vote_count").html(answer.vote_count)

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
