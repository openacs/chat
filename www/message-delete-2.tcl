#/chat/www/message-delete-2.tcl
ad_page_contract {
    Delete messages in the room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date January 18, 2001
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
}

permission::require_permission -object_id $room_id -privilege chat_room_delete

if { [catch {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r delete_messages
} errmsg] } {
    ad_return_complaint 1 "[_ chat.Delete_messages_failed]: $errmsg"
    ad_script_abort
}

::chat::Chat flush_messages -chat_id $room_id

ad_returnredirect .

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
