# Enable pusher logging - don't include this in production
Pusher.log = (message) ->
  window.console.log(message) if (window.console && window.console.log)

gameChannel = pusher.subscribe('private-game-events')
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
