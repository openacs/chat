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

::chat::Chat c1 -volatile -chat_id $id -session_id $s

switch -- $m {
  add_msg {
    if { [string length $msg] > 200 } {
      set msg [string range $msg 0 200]
    }
    set _ [c1 $m $msg]
    
    set user_id [ad_conn user_id]
    chat_message_post $id $user_id $msg f

     # ns_log notice "--c add_msg returns '$_' -chat_id:$id -session_id:$s msg:$msg m:$m"
  }
  login -
  get_new -
  get_all {set _ [c1 $m]}
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
</style>
<body style='margin:0px; padding:5px;'>
<div id='messages'>$_</div>
</body>
</HTML>"