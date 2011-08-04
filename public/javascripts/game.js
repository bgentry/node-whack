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
      var displayName;
      displayName = info.nickname.length > 20 ? "" + (info.nickname.substring(0, 17)) + "..." : info.nickname;
      return $(this).append("<li class='user' data-nickname='" + info.nickname + "' data-id='" + id + "'><span class='score'>" + (userScores[info.nickname] || 0) + "</span><span class='nickname'>" + displayName + "</span></li>");
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
        user_nickname: currentUserNickname,
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
    $(".messageArea").html("Game over! The winner was " + data.user_nickname);
    userScores[data.user_nickname] = data.score;
    $(".user[data-nickname='" + data.user_nickname + "'] .score").html(data.score);
    return $("#start-game-button").show();
  });
  clearMoleAndBinding = function() {
    return $("#mole").unbind('click').slideUp(100);
  };
}).call(this);
