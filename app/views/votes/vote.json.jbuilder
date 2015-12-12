json.(@votable, :id, :vote_count)
json.vote_up current_user.vote_up?(@votable)
json.vote_down current_user.vote_down?(@votable)
