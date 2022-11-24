ready = ->
  questionId = $('.question').data('question_id')
  userId = $('.question').data('user_id')

  App.cable.subscriptions.create { channel: 'AnswersChannel', question_id: questionId },
    received: (data) ->
      answer = $.parseJSON(data['answer'])
      vote_count = $.parseJSON(data['vote_count'])
      return if userId == answer.user_id
      $('.answers').append(JST['templates/answer'](answer: answer, vote_count: vote_count))

voteAnswer = (e, data, status, xhr) ->
  answer = $.parseJSON(xhr.responseText)
  $(".answer-#{answer.id}").voteChange(answer)

$(document)
  .ready(ready)
  .on('ajax:success', '.answers .vote-up-off, .answers .vote-up-on, .answers .vote-down-off, .answers .vote-down-on', voteAnswer)
