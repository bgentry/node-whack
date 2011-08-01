(function() {
  var add_member, gameChannel, presenceChannel, remove_member;
  Pusher.log = function(message) {
    if (window.console && window.console.log) {
      return window.console.log(message);
    }
  };
  gameChannel = pusher.subscribe('private-game-events');
  gameChannel.bind('new_game_warning', function(data) {
    return alert(data);
  });
  presenceChannel = pusher.subscribe('presence-game');
  presenceChannel.bind('pusher:subscription_succeeded', function(members) {
    console.log('subscription succeeded');
    $('.user-count').html("(" + members.count + ")");
    return members.each(function(member) {
      return add_member(member.id, member.info);
    });
  });
  presenceChannel.bind('pusher:member_added', function(member) {
    console.log('member added');
    return add_member(member.id, member.info);
  });
  presenceChannel.bind('pusher:member_removed', function(member) {
    return remove_member(member.id, member.info);
  });
  add_member = function(id, info) {
    return $('.user-list').fadeIn(function() {
      return $(this).append("<ul class='user' data-email='" + info.email + "' data-id='" + id + "'>" + info.email + "</ul>");
    });
  };
  remove_member = function(id, info) {
    return $(".user[data-id='" + id + "']").fadeOut(function() {
      return $(this).remove();
    });
  };
}).call(this);
