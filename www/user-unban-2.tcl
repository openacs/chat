#/chat/www/user-unban-2.tcl
ad_page_contract {

    Unban chat user

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
    party_id:naturalnum,notnull
}

permission::require_permission -object_id $room_id -privilege chat_user_unban

set room [::xo::db::Class get_instance_from_db -id $room_id]
$room unban_user -party_id $party_id

ad_returnredirect "room?room_id=$room_id"

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
