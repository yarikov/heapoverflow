ready = ->
  $('#update-avatar').change ->
    $(this).submit()

  $('#change-picture').click ->
    $('#user_avatar').click()

  $('#update-avatar').on "ajax:success", (e, data, status, xhr)->
    @user = $.parseJSON(xhr.responseText)
    $('.gravatar-wrapper img').attr('src', @user.user.avatar.avatar.url)

$(document).ready(ready)
