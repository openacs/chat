#/chat/www/user-ban.tcl
ad_page_contract {

    Explicit ban user from the chat room.

    @author David Dao (ddao@arsdigita.com)
    @creation-date November 22, 2000
    @cvs-id $Id$
} {
    room_id:object_type(chat_room)
} -properties {
    context_bar:onevalue
    title:onevalue
    action:onevalue
    submit_label:onevalue
    room_id:onevalue
    description:onevalue
    parties:multirow
}

permission::require_permission -object_id $room_id -privilege chat_user_ban

set context_bar [list "[_ chat.Ban_user]"]
set submit_label "[_ chat.Ban]"
set title "[_ chat.Ban_user]"
set action "user-ban-2"
set r [::xo::db::Class get_instance_from_db -id $room_id]
set room_name [$r set pretty_name]
set description "[_ chat.Ban_chat_read_write] <b>$room_name</b> [_ chat.to]"
db_multirow parties list_parties {
    select party_id, acs_object.name(party_id) as name
    from parties
}

ad_return_template grant-entry

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
