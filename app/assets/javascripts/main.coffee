$.fn.voteChange = (obj) ->
  $(this).find('.vote_count').html(obj.vote_count)
  if obj.vote_up
    $(this).find('.vote-up-off').toggleClass('vote-up-off vote-up-on')
    $(this).find('.vote-down-on').toggleClass('vote-down-on vote-down-off')
  else if obj.vote_down
    $(this).find('.vote-up-on').toggleClass('vote-up-on vote-up-off')
    $(this).find('.vote-down-off').toggleClass('vote-down-off vote-down-on')
  else
    $(this).find('.vote-up-on').toggleClass('vote-up-on vote-up-off')
    $(this).find('.vote-down-on').toggleClass('vote-down-on vote-down-off')
