#/chat/www/room-delete.tcl
ad_page_contract {
    Display delete confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id$
} {
    room_id:notnull,integer
} -properties {
    room_id:onevalue
    pretty_name:onevalue
    context_bar:onevalue
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Delete_room]"]

set pretty_name [chat_room_name $room_id]

ad_return_template