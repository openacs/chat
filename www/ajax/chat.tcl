ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id$
} -query {
  m
  id
  s
  {msg ""}
}

set message_output ""
set user_output ""

::chat::Chat c1 -volatile -chat_id $id -session_id $s

switch -- $m {
  add_msg {
    # do not allow messages longer than 200 characters
    if { [string length $msg] > 200 } {
      set msg [string range $msg 0 200]
    }
    # do not insert empty messages, if they managed to get here
    if { $msg ne "" } {
        set message_output [c1 $m $msg]
        set user_id [ad_conn user_id]
        chat_message_post $id $user_id $msg f
    }
  }
  login - get_new - get_all {
    set message_output [c1 $m]
  } 
  get_updates {
      set message_output [c1 get_new]
      set user_output [c1 get_users]
  }
  get_users {
    c1 encoder noencode
    set user_output [c1 get_users]
  }
  default {ns_log error "--c unknown method $m called."} 
}

ns_return 200 text/html "
<HTML>
<style type='text/css'>
#messages { font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#messages .timestamp {vertical-align: top; color: #CCCCCC; }
#messages .user {margin: 0px 5px; text-align: right; vertical-align: top; font-weight:bold;}
#messages .message {vertical-align: top;}
#messages .line {margin:0px;}
#users { width: 100%; font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#users .user {text-align: left; vertical-align: top; font-weight:bold; }
#users .timestamp {text-align: right; vertical-align: top; }
</style>
<body style='margin:0px; padding:5px;'><div id='messages'>$message_output</div><table id='users'><tbody>$user_output</tbody></table></body>
</HTML>"