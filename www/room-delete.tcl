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

ad_require_permission $room_id chat_room_delete

set context_bar [ad_context_bar [list "room?room_id=$room_id" "Room information"] "Delete room"]

set pretty_name [chat_room_name $room_id]

ad_return_template