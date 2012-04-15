$(document).ready(function() {
  var Spotify = getSpotifyApi(1);
  var Args = Spotify.core.getArguments();
  var Auth = Spotify.require('sp://import/scripts/api/auth');
  var Models = Spotify.require("sp://import/scripts/api/models");
  var trackTemplate = $("#track-template").html();
  var scores = {};
  var eventId = 1;
  var $loginContainer = $("#login-container");
  var $mainContainer = $("#main-container");
  var $trackList = $("#tracks");
  var $addTrackField = $("#add-track");
  var $addTrackButton = $("#add-track-btn");

  var conn = new WebSocket("ws://jordanorelli.com:8080/socket");

  var LIKE_POWER = {
    "neutral": 0,
    "like": 1,
    "love": 2
  };

  var EVENT_ID = "0";

  var getUserId = function() {
    return Models.session.anonymousUserID;
  }

  conn.onopen = function(event) {
    console.log({"open": event});
  };

  conn.onclose = function(event) {
    console.log({"close": event});
  };

  conn.onmessage = function(event) {
    console.log(event);
    var obj = JSON.parse(event.data);
    console.log(obj);
    addTrack("spotify:track:" + obj["track_id"]);
  };

  // Given an input element and a button element, disables the button if the
  // input field is empty.
  var setButtonBehavior = function($inputField, $submitButton){
    var value = $.trim($inputField.val());

    if(value){
      $submitButton.removeAttr("disabled");
    } else {
      $submitButton.attr("disabled", "disabled");
    }
  };

  var notifyNewTrack = function(track) {
    conn.send(JSON.stringify({
      "cmd": "start_track",
      "params": {
        "track": track
      }
    }));
  }

  var notifyNewPosition = function(position) {
    conn.send(JSON.stringify({
      "cmd": "new_position",
      "params": {
        "track": track,
        "position": position
      }
    }));
  }

  var upvote = function(id, power) {
    conn.send(JSON.stringify({
      "cmd": "upvote_track",
      "params": {
        "event_id": EVENT_ID,
        "track_id": id,
        "user_id": getUserId(),
        "power": power
      }
    }));
  };

  var mkUpvoteHandler = function(id) {
    console.log("Making upvote handler");
    return function(event) {
      console.log("Upvote " + id);
      upvote(id, LIKE_POWER.like);
    };
  };

  var addTrack = function(uri) {
    console.log("inside addTrack" + uri);
    var track = Models.Track.fromURI(uri);
    var id = stripTrackId(track.data.uri);
    $trackList.append(renderTrack(track));
    $("#upvote-track-" + id).click(mkUpvoteHandler(id));
    console.log(track);
  }

  // given a spotify uri, strips the track id (for use in css-selectors)
  var stripTrackId = function(uri) {
    var segments = uri.split(":");
    return segments[segments.length-1];
  };

  // given a raw track response from the spotify api, render it to an html
  // string for injection
  var renderTrack = function(track) {
    var raw = Mustache.to_html(trackTemplate, {"track": track.data, "id": stripTrackId(track.data.uri)});
    console.log(raw);
    return raw;
  };

  $('#add-event-btn').click(function(event) {
    event.preventDefault();
    var eventId = $('div#login-container input:text[name="event_id"]').val();
    console.debug("event ID: " + eventId);
    if (eventId.length == 0 || eventId === '') {
      console.error("event ID: " + eventId);
      alert("Invalid event ID!");
    } else {
      login(eventId);
      $loginContainer.fadeOut(function() {
        $mainContainer.fadeIn();
      });
    }
  });

  $('#add-facebook-btn').click(function(event) {
    event.preventDefault();
    Auth.authenticateWithFacebook('322455194489117', ['user_events', 'user_checkins'], {
      onSuccess : function(accessToken, ttl) {
        console.log("Success! Here's the access token: " + accessToken);
        var fullUrl = "https://graph.facebook.com/me/events/attending?access_token=" + accessToken;

        $.ajax(fullUrl, {
          cache: false,
          dataType: 'json',
          beforeSend: function(result) {
            console.log("beforeSend");
          },
          success: function(result) {
            var parties = result.data;
            for (i in parties) {
              var party = parties[i];
              var name = party.name; 
              $('ul#list-events').append('<li>' + name + '</li>');
            }
          },
          error: function(result) {
            console.log("error: " + result);
          }
        });
      },
      onFailure : function(error) {
        console.log("Authentication failed with error: " + error);
      },
      onComplete : function() { }
    });
  });

  $addTrackButton.click(function(event) {
    var trackName = $.trim($addTrackField.val());
    console.log("add track " + trackName);
    $(this).attr("disabled", "disabled");
    $addTrackField.val("");
    conn.send(JSON.stringify({
      "cmd": "add_track",
      "params": {
        "track_id": stripTrackId(trackName),
        "user_id": "0"
      }
    }));
  });

  $addTrackField.keydown(function(event) {
    if(event.keyCode == 13 && !event.shiftKey) {
      if($.trim($addTrackField.val())) {
        $addTrackButton.click();
      } else {
        return false;
      }
    }
  });

  var setScore = function(item, vote){
    var score = $("#"+ item + "_score");
    score.text(parseInt(vote)); // set score
    reorderList(item); // check order
  }

  // given a newly changed item, reorders the track list accordingly
  var reorderList = function(item){
    var items = $('.track span').get();
    //sort list
    items.sort(function(a,b){
      var keyA = parseInt($(a).text());
      var keyB = parseInt($(b).text());

      if (keyA > keyB) return -1;
      if (keyA < keyB) return 1;
      return 0;
    });

    // insert at the correct location
    var ul = $('.song_list');
    var previous = 0;

    // loop through ordered items to find insert index
    $.each(items, function(i, li){
      var id = li.id.split("_");
      if(id[0] == item){//found location to insert
        // remove item from list
        var element = $("#"+item);
        $("#"+item).remove();

        if(i==0){
          $('.song_list').prepend(element);
        }
        else{
          $('.song_list li:nth-child('+i+')').after(element);
        }
        return false;
      }
    });
  }

  var login = function(eventId){
    conn.send(JSON.stringify({
      "cmd": "login",
      "params": {
        "user_id": getUserId(),
        "event_id": eventId,
      }
    }));
  }

  // tabs();
  // Models.application.observe(Models.EVENT.ARGUMENTSCHANGED, tabs);

  console.log("Hello world!");
  Models.player.observe(Models.EVENT.CHANGE, function(event) {
    //console.log("Something changed!");
    //console.log("here's what changed: " + event);

    if(event.data.contextclear) {
      // ???
    } else if(event.data.curcontext) {
      // ???
    } else if(event.data.curtrack) {
      // New track
      var track = Models.player.track;
      console.log("NEW track: " + track);
      notifyNewTrack(track);
    } else if(event.data.playstate) {
      // Play / pause
    } else if(event.data.repeat) {
      // NOP
    } else if(event.data.shuffle) {
      // NOP
    } else if(event.data.volume) {
      // NOP
    } else {
      // Must have been ffwd/rewind
      var totalSeconds = Models.player.position / 1000;

      var minutes = Math.floor(totalSeconds / 60);
      var seconds = totalSeconds % 60;

      console.log("current playback position: " + minutes + ":" + seconds);
      notifyNewPosition(Models.player.position);
    }

  });

  function tabs() {
    var args = Models.application.arguments;
    //console.log("Argument: " + args[0]);
    $('.section').hide();
    $('#'+args[0]).show();
  }



});
