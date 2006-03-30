ad_page_contract {
  realtime user list for a chat room

  @author Peter Alberer (peter.alberer@wu-wien.ac.at)
  @creation-date Mar 10, 2006
} -query {
  id
  s
  {m:optional "update"}
}
#after 1000
::chat::Chat c1 -volatile -chat_id $id -session_id $s
if { $m eq "login" } { c1 encoder noencode }
set output ""
foreach {user_id timestamp} [c1 active_user_list] {
  if {$user_id > 0} {
      set diff [clock format [expr {[clock seconds] - $timestamp}] -format "%H:%M:%S" -gmt 1]
    append output "<TR><TD class='user'>[c1 user_link $user_id]</TD><TD class='timestamp'>$diff</TD></TR>\n"
  }
}

ns_return 200 text/html "
<HTML>
<style type='text/css'>
#users { width: 100%; font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#users .user {text-align: left; vertical-align: top; font-weight:bold; }
#users .timestamp {text-align: right; vertical-align: top; }
</style>
<body style='margin:0px; padding:5px;'>
<table id='users'><tbody>$output</tbody></table>
</body>
</HTML>"
