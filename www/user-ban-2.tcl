#/chat/www/user-ban-2.tcl
ad_page_contract {

    Ban user.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
    party_id:object_type(party)
}

permission::require_permission -object_id $room_id -privilege chat_user_ban

set room [::xo::db::Class get_instance_from_db -id $room_id]
$room ban_user -party_id $party_id

ad_returnredirect "room?room_id=$room_id"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
