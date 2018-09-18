ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at)
  @creation-date Jan 31, 2006
  @cvs-id $Id$
} -query {
  m
  id
  s
  {msg:optional,allhtml ""}
}

set ban_p [permission::permission_p -object_id $id -privilege "chat_ban"]
if {$ban_p} {
  ad_return_forbidden
  ad_script_abort
}

set message_output ""
set user_output ""

::chat::Chat c1 -volatile -chat_id $id -session_id $s

switch -- $m {
  add_msg {
      set message_output [c1 add_msg $msg]
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
  default {
      ns_log error "--c unknown method $m called."
  }
}

set output ""
if { $message_output ne "" } {
    append output "<div id='messages'>$message_output</div>"
}
if { $user_output ne "" } {
    append output "<table id='users'><tbody>$user_output</tbody></table>"
}
