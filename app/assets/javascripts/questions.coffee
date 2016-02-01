ready = ->
  questionId = $('.question').data('questionId')
  userId = $('.question').data('userId')

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

editQuestion = (e) ->
  e.preventDefault()
  $(this).text (i, text) ->
    if text is 'Редактировать' then 'Закрыть' else 'Редактировать'
  $(this).toggleClass('btn-warning btn-info')
  $("form.edit_question").toggle()

voteQuestion = (e, data, status, xhr) ->
  question = $.parseJSON(xhr.responseText)
  $('.question').voteChange(question)

newComment = (e) ->
  e.preventDefault()
  $(this).text (i, text) ->
    if text is 'Добавить комментарий' then 'Закрыть' else 'Добавить комментарий'
  $(this).toggleClass('btn-primary btn-info')
  $(this).parent().find('.new_comment').toggle()

showError = (e, data, status, xhr) ->
  message = $.parseJSON(data.responseText)
  $('.flash').replaceWith(JST['templates/flash'](error: message.error))

$(document)
  .ready(ready)
  .on('click', '.edit-question-link', editQuestion)
  .on('click', '.new-comment-link', newComment)
  .on('ajax:success', '.question .vote-up-off, .question .vote-up-on, .question .vote-down-off, .question .vote-down-on', voteQuestion)
  .on('ajax:error', showError)
