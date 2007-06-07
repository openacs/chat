ad_page_contract {
  a tiny chat client

  @author Gustaf Neumann (gustaf.neumann@wu-wien.ac.at) and Pablo Muñoz (pablomp@tid.es)
  
} -query {
  m  
  id
  s
  {msg:optional,allhtml ""}  
}
set room [::chat::Chat create new -volatile -chat_id $id]
set active_users [$room nr_active_users]

set user_id [ad_conn user_id]




db_1row room_info {
		select maximal_participants as maximal
		from chat_rooms as cp
		where cp.room_id = :id
}
if { $active_users >= $maximal} {
	#If the user is active and the room is full	
	db_1row room_info {
		select count(chat_room_user_id.user_id) as count
		from chat_room_user_id
		where chat_room_user_id.user_id = :user_id
		and chat_room_user_id.room_id = :id
	}	
	if { $count == 0 } {
			if { [permission::permission_p -party_id $user_id -object_id [dotlrn::get_package_id] -privilege admin] } {
				
			} else {
				#blanco
				
			ns_return 200 text/html "<HTML><BODY>\
			<div id='messages'>[_ chat.You_dont_have_permission_room]</div>\
			</BODY></HTML>"
  			ad_script_abort
  			}
  	}
}

set ban_p [permission::permission_p -object_id $id -privilege "chat_ban"]
if {$ban_p} {
  ns_return 200 text/html "<HTML><BODY>\
	<div id='messages'>[_ chat.You_dont_have_permission_room]</div>\
	</BODY></HTML>"
  ad_script_abort
}

db_1row date {	
        select r.end_date as date, pretty_name as name
        from chat_rooms as r
        where r.room_id = :id        		
	}
if { [clock format [clock seconds] -format "%Y/%m%d"] > $date } {
	db_0or1row update_closed {	
        	update chat_rooms SET open = 'false'        	
        	WHERE room_id = :id;
        	select 1;        	        	
	}
	ns_return 200 text/html "<HTML><BODY>\
	<div id='messages'>[_ chat.closed_room]</div>\
	</BODY></HTML>"
  ad_script_abort
}
set user_id [ad_conn user_id]
db_1row room_info {
		select distinct count(cp.user_id1) as count1
		from chat_private_room_users as cp
		where cp.room_id = :id
		and cp.user_id1 = :user_id		
}

db_1row room_info {
		select distinct count(cp.user_id1) as count2
		from chat_private_room_users as cp
		where cp.room_id = :id
		and cp.user_id2 = :user_id
}
db_1row room_info {
		select cr.private as private
		from chat_rooms as cr
		where cr.room_id = :id
}
if { $count1 == 0 && $count2 == 0 } {
	if { $private eq "t" } {	
		ns_return 200 text/html "<HTML><BODY>\
		<div id='messages'>[_ chat.You_dont_have_permission_room]</div>\
		</BODY></HTML>"
  		ad_script_abort
	}
	
}


set message_output ""
set user_output "-"
set files_output "-"


#crea el objeto de tipo xotcl
::chat::Chat c1 -volatile -chat_id $id -session_id $s

switch -- $m {
  add_msg {
    # i see no reason, why this is limited to 200 characters.... GN
    # do not allow messages longer than 200 characters
    #if { [string length $msg] > 200 } {
    #  set msg [string range $msg 0 200]
    #}
    # do not insert empty messages, if they managed to get here
    if { $msg ne "" } {
        set message_output [c1 add_msg $msg]
        if { [c1 current_message_valid] } {
            chat_message_post $id [c1 user_id] $msg 1
        }
    }
  }
  login - get_new - get_all {
    set message_output [c1 $m]
  }
  get_updates {
  	
      set message_output [c1 get_new]      
      
      set user_output [c1 get_users]
      
      set files_output [c1 get_files]
      
      
  }
  get_users {
    
    c1 encoder noencode
    set user_output [c1 get_users]
    
  }
  get_files {
      
    c1 encoder noencode
    set files_output [c1 get_files]
  }
  default {ns_log error "--c unknown method $m called."} 
}

set output "
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
#files { width: 100%; font-size: 12px; color: #666666; font-family: Trebuchet MS, Lucida Grande, Lucida Sans Unicode, Arial, sans-serif; }
#files .file {text-align: left; vertical-align: top; font-weight:bold; }
</style>
<body id='body' style='margin:0px; padding:5px;'>"

if { $message_output ne "" } {
    append output "<div id='messages'>$message_output</div>\n"
}

if { $user_output ne "-" } {
	
    append output "<table id='users'><tbody>$user_output</tbody></table>\n"
}

if { $files_output ne "-" } {

    append output "<table id='files'><tbody>$files_output</tbody></table>\n"
}

append output "
</body>
</HTML>"

ns_return 200 text/html $output
