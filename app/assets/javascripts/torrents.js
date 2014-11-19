// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.
// You can use CoffeeScript in this file: http://coffeescript.org/
$(document).ready(function() {

  $('#refresh_torrents_button').click(function() {
    console.log("Refresh button pressed.");
    var button_content = $('#refresh_torrents_button').html();
    $('#refresh_torrents_button').html('<img src="/assets/ajax-loader.gif">');
    $.getJSON("/torrents/refresh", function(result) {
      if (result.changed === "true") {
        console.log("Changes found, applying...");
        $('#panel_all').html(result.all); 
        $('#badge_all').html(result.all_count);
        $('#panel_transferring').html(result.transferring); 
        $('#badge_transferring').html(result.transferring_count);
        $('#panel_downloading').html(result.downloading); 
        $('#badge_downloading').html(result.downloading_count);
        $('#panel_seeding').html(result.seeding); 
        $('#badge_seeding').html(result.seeding_count);
        $('#panel_completed').html(result.completed); 
        $('#badge_completed').html(result.completed_count);
        $('#refresh_torrents_button').html(button_content);  
      } else {
        console.log("Refresh resulted in no changes");
        $('#refresh_torrents_button').html(button_content);  
      };
    });
  });

  $('.remove_torrent_button').click(function() {
    var torrent_id = $(this).attr("torrent_id");
    console.log("Removing torrent with local id: "+torrent_id);
    var button_content = $(this).html()
    $(this).html('<img src="/assets/ajax-loader.gif">');
    $.ajax({
      url: '/torrents/'+torrent_id,
      type: 'DELETE',
      success: function(result) {
        if (result.deleted === "true") {
          console.log("success");
          $(".torrent_entry_"+torrent_id).remove();
        } else {
          console.log("failure");
          $(this).html(button_content);
        };
      }
    });
    
  });

});
