#/chat/www/transcript-new.tcl
ad_page_contract {
    Display available all available chat messages.
    @author Pablo Muñoz(pablomp@tid.es)
} {
    room_id:integer,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    room_id:onevalue
    transcript_id:onevalue
    transcript_name:onevalue
    description:onevalue
    contents:onevalue
}

set user_id [ad_conn user_id]
#A professor who creates a rooom will be able to admin it.
db_1row room_info2 {
		select count(cr.creator) as counter2
		from chat_rooms cr
		where cr.room_id = :room_id
		and cr.creator = :user_id		
 }
 if { $counter2 > 0} { 	
 		set admin_professor "t"
 } else {
 	 set admin_professor "f"
 } 
if { $admin_professor eq "t"} {
} else {
permission::require_permission -object_id $room_id -privilege chat_transcript_create
}

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Create_transcript]"]

set transcript_id ""
set transcript_name "[_ chat.transcript_of_date] [clock format [clock seconds] -format "%d.%m.%y %H:%M:%S"]"
set description ""
set contents ""
set action "transcript-new-2"
set title "[_ chat.Create_transcript]"
set submit_label "[_ chat.Create_transcript]"
set active_p [room_active_status $room_id]
set keywords ""



#Build a list of all message.
db_foreach get_archives_messages {} {
	
	if { $creation_user eq "-1" } {
		append contents "\[$creation_date\] <b>System</b>: $msg<br>\n"
	} else {
		db_1row room_info2 {
    			select count(r.alias)
    			from chat_registered_users r
    			where r.user_id = :creation_user
    			and r.room_id = :room_id
		}

		if { $count > 0} {
			db_1row room_info2 {
    				select r.alias
    				from chat_registered_users r
    				where r.user_id = :creation_user
    				and r.room_id = :room_id
			}
			append contents "\[$creation_date\] <b>[chat_user_name2 $creation_user $alias]</b>: $msg<br>\n"
		} else {
	    		append contents "\[$creation_date\] <b>[chat_user_name $creation_user]</b>: $msg<br>\n"
		}
	}
}

ad_return_template "transcript-entry"

