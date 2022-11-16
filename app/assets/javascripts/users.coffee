ready = ->
  $('#update-avatar').change ->
    $(this).submit()

  $('#change-picture').click ->
    $('#user_avatar').click()

  $('#update-avatar').on "ajax:success", (e, data, status, xhr)->
    @user = $.parseJSON(xhr.responseText).user
    $('.gravatar-wrapper img').attr('src', @user.avatar.url)

$(document).ready(ready)
