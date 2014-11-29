// This is a manifest file that'll be compiled into application.js, which will include all the files
// listed below.
//
// Any JavaScript/Coffee file within this directory, lib/assets/javascripts, vendor/assets/javascripts,
// or vendor/assets/javascripts of plugins, if any, can be referenced here using a relative path.
//
// It's not advisable to add code directly here, but if you do, it'll appear at the bottom of the
// compiled file.
//
// Read Sprockets README (https://github.com/sstephenson/sprockets#sprockets-directives) for details
// about supported directives.
//
//= require jquery
//= require jquery_ujs
//= require twitter/bootstrap
//= require turbolinks
//= require_tree .

$(document).ready(function() {

  $('#navbar_torrent_upload').submit(function() {
    console.log("Submitting new torrent...");
    $('#navbar_torrent_upload_submit').html('<img src="/assets/ajax-loader.gif">');
    var valuesToSubmit = $(this).serialize();
    $.post("/torrents", valuesToSubmit, function(result) {
      console.log(result.created);
      if (result.created === "true") {
        $('#navbar_torrent_upload_submit').html("Upload");
        $('#navbar_torrent_upload_text_field').val("");
      } else {
        $('#navbar_torrent_upload_submit').html("Failure");
        $('#navbar_torrent_upload_text_field').val(""); 
      }; 
    });
    return false;
  });

});
