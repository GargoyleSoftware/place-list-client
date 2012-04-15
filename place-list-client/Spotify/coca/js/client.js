$(document).ready(function() {
  var Spotify = getSpotifyApi(1);
  var Args = Spotify.core.getArguments();
  var Auth = Spotify.require('sp://import/scripts/api/auth');
  var Models = Spotify.require("sp://import/scripts/api/models");
  var trackTemplate = $("#track-template").html();
  var eventTemplate = $("#event-template").html();
  var trackSearchTemplate = $("#track-search-template").html();
  var scores = {};
  var eventId = 1;
  var $loginContainer = $("#login-container");
  var $eventContainer = $("#event-container");
  var $mainContainer = $("#main-container");
  var $eventList = $("#list-events");
  var $trackList = $("#tracks");
  var $searchContent = $("#search-content");
  var $searchList = $("#search-list");
  var $addEventButton = $("#add-event-btn");
  var $addFacebookButton = $("#add-facebook-btn");
  var $addTrackField = $("#add-track");
  var $addTrackButton = $("#add-track-btn");
  var fbUser = null;
  var fbToken = null;
  var fbEvent = null;
  var isHost = false;

  var conn = new WebSocket("ws://jordanorelli.com:8080/socket");

  var LIKE_POWER = {
    "neutral": 0,
    "like": 1,
    "love": 2
  };

  var getUserId = function() {
    return Models.session.anonymousUserID;
  }

  conn.onopen = function(event) {
    console.log({"open": event});
  };

  conn.onclose = function(event) {
    alert("socket closed");
    console.log({"close": event});
    setTimeout(function() {
      conn = new WebSocket("ws://jordanorelli.com:8080/socket")
    }, 2000);
  };

  conn.onmessage = function(event) {
    console.log(event);
    var obj = JSON.parse(event.data);
    switch (obj.cmd) {
      case "event_info":
        console.log("event_info");
        console.log(obj);
        $.each(obj.params.upcoming, function(k, v) {
          addTrack("spotify:track:" + k, v);
        });
        break;
      case "add_track":
        console.log("Adding track...");
        console.log(obj);
        addTrack("spotify:track:" + obj.params.track_id, obj.params.upvoters);
        break;
      case "upvote":
        console.log("Upvote!");
        console.log(obj);
        if($.isArray(obj.params.upvoters)) {
          $("#track-" + obj.params.track_id + "-points").html(obj.params.upvoters.length);
        } else {
          $("#track-" + obj.params.track_id + "-points").html(1);
        }
        sortTracks();
        break;
      default:
        console.log("I don't know what to do.");
        console.log(obj);
        break;
    }
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

  var doSearch = function (searchQuery) {
    $searchList.empty();

    var search = new Models.Search(searchQuery);

    search.localResults = Models.LOCALSEARCHRESULTS.APPEND;
    search.observe(Models.EVENT.CHANGE, function() {
      $('div#event-content').hide();
      $searchContent.show();

      search.tracks.forEach(function(track) {
        console.log(track.name);
        $searchList.append(renderSearchTrack(track));
        var id = stripTrackId(track.data.uri);
        $("#track-search-" + id + "-link").click(mkSearchTrackHandler(id));
      });
    });

    search.appendNext();
  }
  
  var notifyAddTrack = function(trackId) {
    conn.send(JSON.stringify({
      "cmd": "add_track",
      "params": {
        "track_id": trackId,
        "user_id": getUserId()
      }
    }));
  }

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
    var $hand = $("#upvote-track-" + id);
    if($hand.hasClass("like")){
      $hand.removeClass("like");
      conn.send(JSON.stringify({
        "cmd": "upvote_track",
        "params": {
          "event_id": eventId,
          "track_id": id,
          "user_id": getUserId(),
          "remove": true
        }
      }));
    } else {
      $hand.addClass("like");
      conn.send(JSON.stringify({
        "cmd": "upvote_track",
        "params": {
          "event_id": eventId,
          "track_id": id,
          "user_id": getUserId(),
          "remove": false
        }
      }));
    }
  };
  
  var mkSearchTrackHandler = function(id) {
    console.log("Making search track handler");
    return function(event) {
      event.preventDefault();
      console.log("track picked for next song " + id);
      notifyAddTrack(id);
    };
  };

  var mkUpvoteHandler = function(id) {
    console.log("Making upvote handler");
    return function(event) {
      console.log("Upvote " + id);
      upvote(id, LIKE_POWER.like);
    };
  };

  var addTrack = function(uri, upvoters) {
    console.log("inside addTrack" + uri);
    Models.Track.fromURI(uri, function(track) {
      console.log(track);
      var id = stripTrackId(track.data.uri);
      $trackList.append(renderTrack(track, upvoters.length));
      if($.inArray(getUserId(), upvoters) !== -1) {
        console.log(getUserId(), " : ", upvoters);
        $("#upvote-track-" + id).addClass("like");
      }
      $("#upvote-track-" + id).click(mkUpvoteHandler(id));
      console.log(track);
      sortTracks();
    });
  }

  // given a spotify uri, strips the track id (for use in css-selectors)
  var stripTrackId = function(uri) {
    var segments = uri.split(":");
    return segments[segments.length-1];
  };

  // given a raw track response from the spotify api, render it to an html
  // string for injection
  var renderTrack = function(track, points) {
    var raw = Mustache.to_html(trackTemplate, {"track": track.data, "id": stripTrackId(track.data.uri), "points": points});
    return raw;
  };

  // given a raw track response from the spotify api, render it to an html
  // string for injection
  var renderSearchTrack = function(track) {
    var raw = Mustache.to_html(trackSearchTemplate, 
      {
      "track": track.data, 
      "name": track.name, 
      "artists": track.artists,
      "id": stripTrackId(track.data.uri)
      });
    return raw;
  };

  var renderEvent = function(event) {
    console.log("render event ------------------------------------------------------------");
    console.log(event);
    return Mustache.to_html(eventTemplate, event)
  };
  
  var joinEventWithId = function(eventId) {
    console.log("event ID: " + eventId);
    if (eventId.length == 0 || eventId === '') {
      console.error("event ID: " + eventId);
      alert("Invalid event ID!");
    } else {
      login(eventId);
      $loginContainer.fadeOut(function() {
        $mainContainer.fadeIn();
      });
    }
  }

  var joinEvent = function(event) {
    event.preventDefault();
    eventId = $('div#login-container input:text[name="event_id"]').val();
    joinEventWithId(eventId);
  };

  $addEventButton.click(joinEvent);

  $addFacebookButton.click(function(event) {
    event.preventDefault();
    Auth.authenticateWithFacebook('322455194489117', ['user_events', 'user_checkins'], {
      onSuccess : function(accessToken, ttl) {
        fbToken = accessToken;
        console.log("Success! Here's the access token: " + accessToken);
        var fullUrl = "https://graph.facebook.com/me/events/attending?access_token=" + accessToken;

        $.ajax(fullUrl, {
          cache: false,
          dataType: 'json',
          beforeSend: function(result) {
            console.log("beforeSend");
          },
          success: function(result) {
            console.log(result);
            $loginContainer.fadeOut(function() {
              $.each(result.data, function(i, event) {
                $eventList.append(renderEvent(event));
                $("#event-" + event.id + "-link").click(function() {
                  login(event.id, event.name);
                  $eventContainer.fadeOut(function() {
                    $mainContainer.fadeIn();
                  });
                });
              });
              $eventContainer.fadeIn();
            });
          },
          error: function(result) {
            console.log("error: " + result);
          }
        });

        $.ajax({
          type: "GET",
          url: "https://graph.facebook.com/me?access_token=" + accessToken,
          async: true,
          dataType: 'json',
          cache: false,
          success: function(data) {
            console.log("Got user's fb details #################");
            console.log(data);
            fbUser = data;
          },
          error: function(XMLHttpRequest, textStatus, errorThrown) {
            console.log("Failed to get user's fb details ----------------");
            console.log([XMLHttpRequest, textStatus, errorThrown]);
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
    doSearch(trackName);
    //var trackName = $.trim($addTrackField.val());
    //console.log("add track " + trackName);
    //$(this).attr("disabled", "disabled");
    //$addTrackField.val("");
    //conn.send(JSON.stringify({
    //  "cmd": "add_track",
    //  "params": {
    //    "track_id": stripTrackId(trackName),
    //    "user_id": getUserId()
    //  }
    //}));
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

  var login = function(id, name){
    eventId = id;
    if(typeof name !== "undefined") {
      $("#event-name").html(name);
    } else {
      $("#event-name").html(id);
    }
    $.ajax({
      type:"GET",
      url: "https://graph.facebook.com/" + id + "?access_token=" + fbToken,
      async: true,
      dataType: 'json',
      cache: false,
      success: function(data) {
        console.log("Got event details");
        console.log(data);
        fbEvent = data;
        if(fbEvent.owner.id == fbUser.id) {
          console.log("You are the host!!!");
          isHost = true;
          $("#event-name").append("(host)");
        } else {
          console.log("You are not the host.  You are " + fbUser.id + " and the host is " + fbEvent.owner.id);
        };
      },
      error: function(XMLHttpRequest, textStatus, errorThrown) {
        console.log("Failed to get event details");
        console.log([XMLHttpRequest, textStatus, errorThrown]);
      }
    });
    conn.send(JSON.stringify({
      "cmd": "login",
      "params": {
        "user_id": getUserId(),
        "event_id": id,
      }
    }));
  }

  var sortTracks = function() {
    console.log("sorting...");
    var tracks = $trackList.children('li').get();
    tracks.sort(function(a, b) {
      var aScore = $(a).find(".count").html();
      var bScore = $(b).find(".count").html();
      return aScore < bScore ? 1 : aScore > bScore ? -1 : 0;
    });
    $trackList.html('');
    $.each(tracks, function(i, elem) {
      $trackList.append(elem);
      var id = $(elem).attr('id');
      $hand = $("#upvote-track-" + id);
      console.log({"id": id, "$hand": $hand});
      $hand.click(mkUpvoteHandler(id));
    });
  };

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

  // Event Page: Toggle for adding songs and seeing details
  $("#add-song").click(function () {
    $("#event-search").fadeIn("fast");
  });
  $("#finsihed-adding").click(function () {
    $("#event-search").fadeOut("fast");
  });


  /*
   * If we were started with an event ID or song ID, let's jump to it.
   * URI Scheme: spotify:app:name:arg1:val1:arg2:val2:...:argN:valN.
   */
  var parseStartArguments = function() {
    var app = Models.application;
    var args = app.arguments;
    for (var i = 0; i < args.length; i+= 2) {
      var key = args[i];
      var value = args[i+1];

      console.log("Key: " + key);
      console.log("Value: " + value);

      if (key === 'event_id') {
        joinEventWithId(value);
      }
    }
  };


  Models.application.observe(Models.EVENT.ACTIVATE, function() {
    console.log("Application activated!");
    parseStartArguments();
  });


});
