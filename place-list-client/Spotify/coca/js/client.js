$(document).ready(function() {
  var Spotify = getSpotifyApi(1);
  var Args = Spotify.core.getArguments();
  var Auth = Spotify.require('sp://import/scripts/api/auth');
  var Models = Spotify.require("sp://import/scripts/api/models");
  var trackTemplate = $("#track-template").html();
  var scores = {};
  
  var $trackList = $("#tracks");
  var $addTrackField = $("#add-track");
  var $addTrackButton = $("#add-track-btn");

  var conn = new WebSocket("ws://jordanorelli.com:8080/socket");

  conn.onclose = function(event) {
    console.log({"close": event});
  };

  conn.onmessage = function(event) {
    console.log(event);
    var obj = JSON.parse(event.data);
    console.log(obj);
    addTrack(obj.params.trackname);
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

  var upvote = function(id) {
    conn.send(JSON.stringify({
      "cmd": "upvote_track",
      "params": {
        "track_id": id
      }
    }));
  };

  var downvote = function(id) {
    conn.send(JSON.stringify({
      "cmd": "downvote_track",
      "params": {
        "track_ud": id
      }
    }));
  }

  var mkUpvoteHandler = function(id) {
    return function(event) {
      console.log("Upvote " + id);
    };
  };

  var mkDownvoteHandler = function(id) {
    return function(event) {
      console.log("Downvote " + id);
    };
  };

  var addTrack = function(uri) {
    console.log("inside addTrack" + uri);
    var track = Models.Track.fromURI(uri);
    var id = stripTrackId(track.data.uri);
    $trackList.append(renderTrack(track));
    $("#upvote-track-" + id).click(mkUpvoteHandler(id));
    $("#downvote-track-" + id).click(mkDownvoteHandler(id));
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

  $addTrackButton.click(function(event) {
    var trackName = $.trim($addTrackField.val());
    console.log("add track " + trackName);
    $(this).attr("disabled", "disabled");
    $addTrackField.val("");
    conn.send(JSON.stringify({
      "cmd": "add_track",
      "params": {
        "trackname": trackName
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

  // tabs();
  // Models.application.observe(Models.EVENT.ARGUMENTSCHANGED, tabs);

  console.log("Hello world!");
  Models.player.observe(Models.EVENT.CHANGE, function(event) {
    //console.log("Something changed!");
    //console.log("here's what changed: " + event);

    var totalSeconds = Models.player.position / 1000;

    var minutes = Math.floor(totalSeconds / 60);
    var seconds = totalSeconds % 60;
    console.log("current playback position: " + minutes + ":" + seconds);

    var track = Models.player.track;
    console.log("current track: " + track);

    // TODO: Send these to the server

  });

  function tabs() {
    var args = Models.application.arguments;
    //console.log("Argument: " + args[0]);
    $('.section').hide();
    $('#'+args[0]).show();
  }
});