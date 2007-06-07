#/chat/www/message-delete.tcl
ad_page_contract {
    Display delete message confirmation.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz (pablomp@tid.es)
   
} {
    room_id:notnull,integer
} -properties {
    room_id:onevalue
    pretty_name:onevalue
    message_count:onevalue
    context_bar:onevalue
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
	ad_require_permission $room_id chat_room_delete
}

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Delete_messages]"]

set pretty_name [chat_room_name $room_id]

set message_count [chat_message_count $room_id]

ad_return_template