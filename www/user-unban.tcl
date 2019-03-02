#/chat/www/user-unban.tcl
ad_page_contract {

    Display confirmation before unban user.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
    party_id:naturalnum,notnull
}

permission::require_permission -object_id $room_id -privilege chat_user_unban

set context_bar [list [list "room?room_id=$room_id" "[_ chat.Room_Information]"] "[_ chat.Unban_user]"]

set party_pretty_name [acs_object_name $party_id]

set r [::xo::db::Class get_instance_from_db -id $room_id]
set pretty_name [$r set pretty_name]

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
