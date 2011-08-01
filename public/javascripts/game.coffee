# Enable pusher logging - don't include this in production
Pusher.log = (message) ->
  window.console.log(message) if (window.console && window.console.log)

gameChannel = pusher.subscribe('private-game-events')
gameChannel.bind('new_game_warning', (data) ->
  alert(data)
)
presenceChannel = pusher.subscribe('presence-game')

presenceChannel.bind 'pusher:subscription_succeeded', (members) ->
  console.log('subscription succeeded')
  $('.user-count').html("(#{members.count})")

  members.each (member) ->
    add_member(member.id, member.info)

presenceChannel.bind('pusher:member_added', (member) ->
  console.log('member added')
  add_member(member.id, member.info)
)

presenceChannel.bind('pusher:member_removed', (member) ->
  remove_member(member.id, member.info)
)

add_member = (id, info) ->
  $('.user-list').fadeIn () ->
    $(this).append("<ul class='user' data-email='#{info.email}' data-id='#{id}'>#{info.email}</ul>")

remove_member = (id, info) ->
  $(".user[data-id='#{id}']").fadeOut () ->
    $(this).remove()
