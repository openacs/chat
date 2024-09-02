#/chat/www/moderator-revoke.tcl
ad_page_contract {

    Display confirmation before remove moderator privilege from a room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
    party_id:naturalnum,notnull
}

permission::require_permission -object_id $room_id -privilege chat_moderator_revoke

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Revoke_moderator]"]

set party_pretty_name [acs_object_name $party_id]

set r [::xo::db::Class get_instance_from_db -id $room_id]
set pretty_name [$r set pretty_name]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
