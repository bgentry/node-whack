# Enable pusher logging - don't include this in production
Pusher.log = (message) ->
  window.console.log(message) if (window.console && window.console.log)

gameChannel = pusher.subscribe('private-game')
gameChannel.bind 'new_game_warning', (data) ->
  alert(data)

presenceChannel = pusher.subscribe('presence-game')
membersOnlineCount = 0

presenceChannel.bind 'pusher:subscription_succeeded', (members) ->
  console.log('subscription succeeded')
  membersOnlineCount = members.count
  $('.user-count').html("(#{membersOnlineCount})")

  members.each (member) ->
    add_member(member.id, member.info)

presenceChannel.bind 'pusher:member_added', (member) ->
  membersOnlineCount++
  update_member_count()
  add_member(member.id, member.info)

presenceChannel.bind 'pusher:member_removed', (member) ->
  membersOnlineCount-- unless membersOnlineCount == 0
  update_member_count()
  remove_member(member.id, member.info)

add_member = (id, info) ->
  $('.user-list').fadeIn () ->
    $(this).append("<ul class='user' data-email='#{info.email}' data-id='#{id}'>#{info.email}</ul>")

remove_member = (id, info) ->
  $(".user[data-id='#{id}']").fadeOut () ->
    $(this).remove()

update_member_count = () ->
  $('.user-count').fadeIn () ->
    $(this).html("(#{membersOnlineCount})")

# Game events
gameChannel.bind 'new-game-starting', (data) ->
  $("#start_game_button").hide()
  $(".message_area").html("A new game is starting soon. Get ready!")

gameChannel.bind 'client-new-game-requested', (data) ->
  # Hiding on the client event gets a faster response than waiting for the
  # server to notify us of an impending game
  $("#start_game_button").hide()

$("#start_game_button").live 'click', () ->
  $(this).hide()
  gameChannel.trigger("client-new-game-requested", { user_id: currentUserId })

gameChannel.bind 'new-game', (data) ->
  $("#whack_mole").bind 'click', () ->
    gameChannel.trigger('client-whack', {
      game_token: $(this).data('token'),
      user_id: currentUserId
    })
    clearMoleAndBinding()
  $("#whack_mole").data('token', data.game_token).show()
  $(".message_area").html("Whack the mole!!")

gameChannel.bind 'client-whack', (data) ->
  # Another user has whacked. Remove the mole if the token is correct
  if $("#whack_mole").data('token') == data.game_token
    clearMoleAndBinding()

gameChannel.bind 'game-over', (data) ->
  clearMoleAndBinding()
  $(".message_area").html("Game over! The winner was #{data.user_id}")
  $("#start_game_button").show()

clearMoleAndBinding = () ->
  # Remove the game token and click binding
  $("#whack_mole").data('token', null).unbind('click').hide()
