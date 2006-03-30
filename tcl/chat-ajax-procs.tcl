ad_library {
    chat - chat procs

    @creation-date 2006-02-02
    @author Gustaf Neumann
    @cvs-id $Id$  
}

namespace eval ::chat {
  ::xo::ChatClass Chat -superclass ::xo::Chat

  Chat proc login {-chat_id -package_id} {
    auth::require_login
    if {![info exists package_id]} {set package_id [ad_conn package_id] }
    if {![info exists chat_id]}    {set chat_id $package_id }

    set context id=$chat_id&s=[ad_conn session_id].[clock seconds]
    set path packages/chat/www/ajax/chat.js
    if { ![file exists [acs_root_dir]/$path] } {
      return -code error "File [acs_root_dir]/$path does not exist"
    }
    set file [open [acs_root_dir]/$path]; set js [read $file]; close $file
    #set location  [util_current_location]
    set path      [site_node::get_url_from_object_id -object_id $package_id]
    set login_url $path/ajax/chat?m=login&$context
    set send_url  $path/ajax/chat?m=add_msg&$context&msg=
    set users_url $path/ajax/users?m=login&$context
    #set get_update  "chatUpdateData()"
    #chatSendCmd(\"$path/ajax/chat?m=get_new&$context\",chatReceiver)"
    set get_userlist "chatUpdateUserList(\"$users_url\",usersReceiver)"
    #set get_all     "chatSendCmd(\"$path/ajax/chat?m=get_all&$context\",chatReceiver)"
    return "\
      <script type='text/javascript' language='javascript'>
      $js
      // register the three data sources (for sending messages, receiving messages and the user list)
      var pushMessage = registerDataConnection(pushReceiver, '$path/ajax/chat?m=get_new&$context', false);
      var pullMessage = registerDataConnection(messagesReceiver, '$path/ajax/chat?m=get_new&$context', true);
      var onlineUsers  = registerDataConnection(usersReceiver, '$path/ajax/users?$context', true);
      // register an update function to refresh the data sources every 5 seconds
      var updateInterval = setInterval(updateDataConnections,5000);
      </script>
      <form name='ichat_form' action='#' onsubmit='pushMessage.chatSendMsg(\"$send_url\"); return false;'>
      <iframe name='ichat' id='ichat' frameborder='0' src='$login_url'
          style='width:70%; border:1px solid black; padding:2px; margin-right:15px;' height='250'></iframe>
      <iframe name='ichat-users' id='ichat-users' frameborder='0' src='$users_url'
          style='width:25%; border:1px solid black; padding:2px;' height='250'></iframe>
      <div style='margin-top:10px;'>
      #chat.message# <input type='text' size='80' name='msg' id='chatMsg'>
      <input type=submit value='#chat.Send_Refresh#'>
      </div>
      </form> 
    "
  }
}

