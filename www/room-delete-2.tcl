#/chat/www/room-delete-2.tcl
ad_page_contract {
    Delete the chat room.

    @author David Dao (ddao@arsdigita.com) and Pablo Muñoz(pablomp@tid.es)
    @creation-date November 16, 2000
    @cvs-id $Id$
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
ad_require_permission $room_id chat_room_delete
}

if { [catch {chat_room_delete $room_id} errmsg] } {
    ad_return_complaint 1 "[_ chat.Delete_room_failed]: $errmsg"
}

ad_returnredirect . 




