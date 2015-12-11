ready = ->
  $('.edit-question-link').click (e) ->
    e.preventDefault();
    $(this).hide();
    question_id = $(this).data('questionId')
    $('form#edit_question_' + question_id).show()

  $('.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on').bind 'ajax:success', (e, data, status, xhr) ->
    question = user = $.parseJSON(xhr.responseText)
    $('.question .vote_count').html(question.vote_count)
    if user.vote_up
      $('.question .vote-up-off').removeClass('vote-up-off').addClass('vote-up-on')
      $('.question .vote-down-on').removeClass('vote-down-on').addClass('vote-down-off')
    else if user.vote_down
      $('.question .vote-up-on').removeClass('vote-up-on').addClass('vote-up-off')
      $('.question .vote-down-off').removeClass('vote-down-off').addClass('vote-down-on')
    else
      $('.question .vote-up-on').removeClass('vote-up-on').addClass('vote-up-off')
      $('.question .vote-down-on').removeClass('vote-down-on').addClass('vote-down-off')

$(document).ready(ready)
$(document).on('page:load', ready)
$(document).on('page:update', ready)
