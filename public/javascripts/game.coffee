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
    displayName = if (info.nickname.length > 20) then "#{info.nickname.substring(0,17)}..." else info.nickname
    $(this).append("<li class='user' data-nickname='#{info.nickname}' data-id='#{id}'><span class='score'>#{userScores[info.nickname] || 0}</span><span class='nickname'>#{displayName}</span></li>")

remove_member = (id, info) ->
  $(".user[data-id='#{id}']").fadeOut () ->
    $(this).remove()

update_member_count = () ->
  $('.user-count').fadeIn () ->
    $(this).html("(#{membersOnlineCount})")

# Game events
gameChannel.bind 'new-game-starting', (data) ->
  $("#start-game-button").hide()
  showMessageAndAnimate("A new game is starting soon. Get ready!")

gameChannel.bind 'client-new-game-requested', (data) ->
  # Hiding on the client event gets a faster response than waiting for the
  # server to notify us of an impending game
  $("#start-game-button").hide()

$("#start-game-button").live 'click', () ->
  $(this).hide()
  gameChannel.trigger("client-new-game-requested", { user_id: currentUserId })

gameChannel.bind 'new-game', (data) ->
  $("#mole").bind 'click', () ->
    gameChannel.trigger 'client-whack', {
      game_token: $(this).data('token'),
      user_nickname: currentUserNickname,
      user_id: currentUserId
    }
    clearMoleAndBinding()
  $("#mole").css('bottom', data.position.y).css('left', data.position.x).data('token', data.game_token).slideDown('fast')
  showMessageAndAnimate("Whack the mole!!")

gameChannel.bind 'client-whack', (data) ->
  # Another user has whacked. Remove the mole if the token is correct
  if $("#mole").data('token') == data.game_token
    clearMoleAndBinding()

gameChannel.bind 'game-over', (data) ->
  clearMoleAndBinding()
  showMessageAndAnimate("Game over! The winner was #{data.user_nickname}")
  userScores[data.user_nickname] = data.score
  $(".user[data-nickname='#{data.user_nickname}'] .score").html(data.score)
  $("#start-game-button").show()

clearMoleAndBinding = () ->
  # Remove the game token and click binding
  $("#mole").unbind('click').slideUp(100)

showMessageAndAnimate = (text) ->
  $(".messageArea").html(text).effect("highlight", {}, 1000)
