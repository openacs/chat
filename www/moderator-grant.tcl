#/chat/www/moderator-grant.tcl
ad_page_contract {

    Add moderator to a room.
    @author David Dao (ddao@arsdigita.com)
    @creation-date November 16, 2000
    @cvs-id $Id$
} {
    room_id:naturalnum,notnull
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    room_id:onevalue
    description:onevalue
    parties:multirow
}

permission::require_permission -object_id $room_id -privilege chat_moderator_grant

set context_bar [list "[_ chat.Grant_moderator]"]
set submit_label "[_ chat.Grant]"
set title "[_ chat.Grant_moderator]"
set action "moderator-grant-2"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set room_name [$r set pretty_name]
set description "[_ chat.Grant_moderator_for] <b>$room_name</b> [_ chat.to]"
db_multirow parties list_parties {}

ad_return_template grant-entry

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
