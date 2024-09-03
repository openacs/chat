#/chat/www/message-delete-2.tcl
ad_page_contract {
    Delete messages in the room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date January 18, 2001
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

set r [::xo::db::Class get_instance_from_db -id $room_id]
$r delete_messages

::chat::Chat flush_messages -chat_id $room_id

ad_returnredirect .

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
