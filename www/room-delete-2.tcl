#/chat/www/room-delete-2.tcl
ad_page_contract {
    Delete the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 16, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

set r [::xo::db::Class get_instance_from_db -id $room_id]
$r delete

ad_returnredirect .

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
