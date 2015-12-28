ready = ->
  questionId = $('.question').data('questionId')
  userId = $('.question').data('userId')

  PrivatePub.subscribe "/questions/#{questionId}/answers", (data, channel) ->
    answer = $.parseJSON(data['answer'])
    vote_count = $.parseJSON(data['vote_count'])
    return if userId == answer.user_id
    $('.answers').append(JST['templates/answer'](answer: answer, vote_count: vote_count))

editAnswer = (e) ->
  e.preventDefault();
  $(this).hide();
  answerId = $(this).data('answerId')
  $("form#edit-answer-#{answerId}").show()

voteAnswer = (e, data, status, xhr) ->
  answer = $.parseJSON(xhr.responseText)
  $(".answer-#{answer.id}").voteChange(answer)

$(document)
  .ready(ready)
  .on('click', '.edit-answer-link', editAnswer)
  .on('ajax:success', '.answers .vote-up-off, .answers .vote-up-on, .answers .vote-down-off, .answers .vote-down-on', voteAnswer)
