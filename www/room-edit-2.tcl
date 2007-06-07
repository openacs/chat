#/www/chat/room-edit-2.tcl
ad_page_contract {
    Update room information.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id$
} {
    room_id:notnull,integer
    pretty_name:notnull,trim
    {description:trim ""}
    {moderated_p "f"}
    {archive_p "f"}
    {active_p "f"}
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
ad_require_permission $room_id chat_room_edit
}


if {[catch {chat_room_edit $room_id $pretty_name $description $moderated_p $active_p $archive_p} errmsg]} {

    ad_return_complaint 1 "[_ chat.Could_not_update_room]: $errmsg"
}


ad_returnredirect "room?room_id=$room_id"





