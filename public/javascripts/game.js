(function() {
  var add_member, clearMoleAndBinding, gameChannel, membersOnlineCount, presenceChannel, remove_member, update_member_count;
  Pusher.log = function(message) {
    if (window.console && window.console.log) {
      return window.console.log(message);
    }
  };
  gameChannel = pusher.subscribe('private-game');
  gameChannel.bind('new_game_warning', function(data) {
    return alert(data);
  });
  presenceChannel = pusher.subscribe('presence-game');
  membersOnlineCount = 0;
  presenceChannel.bind('pusher:subscription_succeeded', function(members) {
    console.log('subscription succeeded');
    membersOnlineCount = members.count;
    $('.user-count').html("(" + membersOnlineCount + ")");
    return members.each(function(member) {
      return add_member(member.id, member.info);
    });
  });
  presenceChannel.bind('pusher:member_added', function(member) {
    membersOnlineCount++;
    update_member_count();
    return add_member(member.id, member.info);
  });
  presenceChannel.bind('pusher:member_removed', function(member) {
    if (membersOnlineCount !== 0) {
      membersOnlineCount--;
    }
    update_member_count();
    return remove_member(member.id, member.info);
  });
  add_member = function(id, info) {
    return $('.user-list').fadeIn(function() {
      return $(this).append("<ul class='user' data-email='" + info.email + "' data-id='" + id + "'><span class='score'>" + (userScores[info.email] || 0) + "</span><span class='email'>" + info.email + "</span></ul>");
    });
  };
  remove_member = function(id, info) {
    return $(".user[data-id='" + id + "']").fadeOut(function() {
      return $(this).remove();
    });
  };
  update_member_count = function() {
    return $('.user-count').fadeIn(function() {
      return $(this).html("(" + membersOnlineCount + ")");
    });
  };
  gameChannel.bind('new-game-starting', function(data) {
    $("#start-game-button").hide();
    return $(".messageArea").html("A new game is starting soon. Get ready!");
  });
  gameChannel.bind('client-new-game-requested', function(data) {
    return $("#start-game-button").hide();
  });
  $("#start-game-button").live('click', function() {
    $(this).hide();
    return gameChannel.trigger("client-new-game-requested", {
      user_id: currentUserId
    });
  });
  gameChannel.bind('new-game', function(data) {
    $("#mole").bind('click', function() {
      gameChannel.trigger('client-whack', {
        game_token: $(this).data('token'),
        user_email: currentUserEmail,
        user_id: currentUserId
      });
      return clearMoleAndBinding();
    });
    $("#mole").css('bottom', data.position.y).css('left', data.position.x).data('token', data.game_token).slideDown('fast');
    return $(".messageArea").html("Whack the mole!!");
  });
  gameChannel.bind('client-whack', function(data) {
    if ($("#mole").data('token') === data.game_token) {
      return clearMoleAndBinding();
    }
  });
  gameChannel.bind('game-over', function(data) {
    clearMoleAndBinding();
    $(".message_area").html("Game over! The winner was " + data.user_email);
    userScores[data.user_email] = data.score;
    $(".user[data-email='" + data.user_email + "'] .score").html(data.score);
    return $("#start-game-button").show();
  });
  clearMoleAndBinding = function() {
    return $("#mole").unbind('click').slideUp(100);
  };
}).call(this);
