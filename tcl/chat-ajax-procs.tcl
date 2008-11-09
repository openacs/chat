ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @author Peter Alberer
    @cvs-id $Id$  
}

namespace eval ::chat {
  ::xo::ChatClass Chat -superclass ::xo::Chat

  Chat instproc render {} {
    my orderby time
    set result ""
    foreach child [my children] {
      set msg       [$child msg]
      set user_id   [$child user_id]
      set color     [$child color]
      set timelong  [clock format [$child time]]
      set timeshort [clock format [$child time] -format {[%H:%M:%S]}]
      set userlink  [my user_link -user_id $user_id -color $color]
      append result "<p class='line'><span class='timestamp'>$timeshort</span>" \
	  "<span class='user'>$userlink:</span>" \
	  "<span class='message'>[my encode $msg]</span></p>\n"
    }
    return $result
  }

  Chat proc login {-chat_id -package_id} {
    auth::require_login
      if {![info exists package_id]} {
          set package_id [ad_conn package_id] 
      }
      if {![info exists chat_id]} {
          set chat_id $package_id 
      }

      set context "id=$chat_id&amp;s=[ad_conn session_id].[clock seconds]"
      set jspath "packages/chat/www/ajax/chat.js"

      if { ![file exists [acs_root_dir]/$jspath] } {
          return -code error "File [acs_root_dir]/$jspath does not exist"
      }
      set file [open [acs_root_dir]/$jspath]; set js [read $file]; close $file

      set path      [site_node::get_url_from_object_id -object_id $package_id]
      set login_url "${path}ajax/chat?m=login&amp;$context"
      set send_url  "${path}ajax/chat?m=add_msg&amp;$context&amp;msg="
      set users_url "${path}ajax/chat?m=get_users&amp;$context"
      return "\
      <script type='text/javascript'>
      $js
      // register the data sources (for sending messages, receiving updates)
      var pushMessage = registerDataConnection(pushReceiver, '$path/ajax/chat?m=get_new&amp;$context', false);
      var pullUpdates = registerDataConnection(updateReceiver, '$path/ajax/chat?m=get_updates&amp;$context', true);
      // register an update function to refresh the data sources every 5 seconds
      var updateInterval = setInterval(updateDataConnections,5000);
      </script>
      <form id='ichat_form' name='ichat_form' action='#' onsubmit='pushMessage.chatSendMsg(\"$send_url\"); return false;'>
      <iframe name='ichat' id='ichat' frameborder='0' src='$login_url'
          style='width:70%; border:1px solid black; margin-right:15px;' height='257'>
      </iframe>
      <iframe name='ichat-users' id='ichat-users' frameborder='0' src='$users_url'
          style='width:25%; border:1px solid black;' height='257'>
      </iframe>
      <div style='margin-top:10px;'>
      #chat.message# <input tabindex='1' type='text' size='80' name='msg' id='chatMsg'>
      <input type='submit' value='#chat.Send_Refresh#'>
      </div>
      </form> 
    "
  }
}

