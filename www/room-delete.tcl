#/chat/www/room-delete.tcl
ad_page_contract {
    Display delete confirmation.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 15, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
} -properties {
    room_id:onevalue
    pretty_name:onevalue
    context_bar:onevalue
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Delete_room]"]

set r [::xo::db::Class get_instance_from_db -id $room_id]
set pretty_name [$r set pretty_name]

ad_return_template

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
