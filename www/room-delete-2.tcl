#/chat/www/room-delete-2.tcl
ad_page_contract {
    Delete the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 16, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
} -validate {
    id_is_a_room -requires room_id {
        if {![::xo::dc 0or1row -prepare integer check_id {
            select 1 from chat_rooms where room_id = :room_id
        }]} {
            ad_complain [_ chat.Room_not_found]
        }
    }
}


permission::require_permission -object_id $room_id -privilege chat_room_delete

if { [catch {
    set r [::xo::db::Class get_instance_from_db -id $room_id]
    $r delete
} errmsg] } {
    ad_return_complaint 1 "[_ chat.Delete_room_failed]: $errmsg"
    ad_script_abort
}

ad_returnredirect .

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
