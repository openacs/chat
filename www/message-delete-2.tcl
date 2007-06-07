#/chat/www/message-delete-2.tcl
ad_page_contract {
    Delete messages in the room.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
    
} {
    room_id:integer,notnull
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
	permission::require_permission -object_id $room_id -privilege chat_room_delete
}


if { [catch {chat_room_message_delete $room_id} errmsg] } {
    ad_return_complaint 1 "[_ chat.Delete_messages_failed]: $errmsg"
}

::chat::Chat flush_messages -chat_id $room_id

ad_returnredirect .
