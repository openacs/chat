#/www/chat/room-edit-2.tcl
ad_page_contract {
    Update room information.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $id$
} {
    room_id:notnull,integer
    pretty_name:notnull,trim
    {description:trim ""}
    {moderated_p "f"}
    {archive_p "f"}
    {active_p "t"}
}

ad_require_permission $room_id chat_room_edit

if {[catch {chat_room_edit $room_id $pretty_name $description $moderated_p $active_p $archive_p} errmsg]} {

    ad_return_complaint "Could not update room" $errmsg
}


ad_returnredirect "room?room_id=$room_id"





