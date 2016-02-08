showCommentForm = (e) ->
  e.preventDefault();
  $(this).parent().siblings('form').show()

updateComment = (e, data, status, xhr) ->
  $(this).hide()
  response = $.parseJSON(xhr.responseText)
  $(this).siblings('.comment-body').html(response.comment.body)

deleteComment = (e, data, status, xhr) ->
  $(this).closest('.comment').remove()

$(document)
  .on('ajax:success', 'a.delete-comment', deleteComment)
  .on('ajax:success', 'form.edit_comment', updateComment)
  .on('click', '.edit-comment', showCommentForm)

