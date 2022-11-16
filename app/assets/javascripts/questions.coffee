ready = ->
  questionId = $('.question').data('question_id')
  userId = $('.question').data('user_id')

  PrivatePub.subscribe "/questions", (data, channel) ->
    question = $.parseJSON(data['question'])
    $('.content').append(JST['templates/question'](question: question))

  PrivatePub.subscribe "/questions/#{questionId}/comments", (data, channel) ->
    comment = $.parseJSON(data['comment'])
    return if userId == comment.user_id
    if comment.commentable_type == 'Question'
      $('.question .comments').append("<div class='comment'>#{comment.body}</div>")
    else
      $(".answer-#{comment.commentable_id} .comments").append("<div class='comment'>#{comment.body}</div>")

voteQuestion = (e, data, status, xhr) ->
  question = $.parseJSON(xhr.responseText)
  $('.question').voteChange(question)

newComment = (e) ->
  e.preventDefault()
  $(this).parent().find('.new_comment').show()

showError = (e, data, status, xhr) ->
  message = $.parseJSON(data.responseText)
  $('.flash').replaceWith(JST['templates/flash'](error: message.error))

$(document)
  .ready(ready)
  .on('click', '.new-comment-link', newComment)
  .on('ajax:success', '.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on', voteQuestion)
  .on('ajax:error', showError)
