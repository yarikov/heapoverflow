ready = ->
  $('.edit-answer-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    answer_id = $(this).data('answerId')
    $('form#edit-answer-' + answer_id).show()

  $('.answers .vote-up-off, .answers .vote-up-on, .answers .vote-down-off, .answers .vote-down-on').bind 'ajax:success', (e, data, status, xhr) ->
    answer = user = $.parseJSON(xhr.responseText)
    $(".answer-#{answer.id} .vote_count").html(answer.vote_count)
    if user.vote_up
      $(".answer-#{answer.id} .vote-up-off").removeClass('vote-up-off').addClass('vote-up-on')
      $(".answer-#{answer.id} .vote-down-on").removeClass('vote-down-on').addClass('vote-down-off')
    else if user.vote_down
      $(".answer-#{answer.id} .vote-up-on").removeClass('vote-up-on').addClass('vote-up-off')
      $(".answer-#{answer.id} .vote-down-off").removeClass('vote-down-off').addClass('vote-down-on')
    else
      $(".answer-#{answer.id} .vote-up-on").removeClass('vote-up-on').addClass('vote-up-off')
      $(".answer-#{answer.id} .vote-down-on").removeClass('vote-down-on').addClass('vote-down-off')

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
